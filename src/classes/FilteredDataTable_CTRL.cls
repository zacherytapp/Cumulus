public with sharing class FilteredDataTable_CTRL {

    @AuraEnabled
    public static String getData(String sObjectName,
            String recordId,
            String whereClause,
            String childObject,
            String relationshipField,
            String fieldSet) {

        FilteredDataTableModel model = new FilteredDataTableModel();

        List<String> fieldNames = UTIL_Describe.listStrFromFieldSet(childObject, fieldSet.toLowerCase());

        model.columns = getColumns(childObject, fieldNames);

        String soql = 'SELECT ' +
                String.join(fieldNames, ', ').removeEnd(', ') +
                ' FROM ' + childObject +
                ' WHERE ' + whereClause.trim() +
                ' AND ' + relationshipField + ' = :recordId';
        List<SObject> data = Database.query(soql);

        model.data = data;

        return JSON.serialize(model);
    }

    public static List<Column> getColumns(String sObjectName, List<String> fields){
        List<Column> columns = new List<Column>();
        for (String field : fields) {
            Schema.DescribeFieldResult dfr = UTIL_Describe.getFieldDescribe(sObjectName, field);
            Column col = new Column();
            col.label = dfr.getLabel();
            col.fieldName = dfr.getName();
            col.type = dfr.getType().name().toLowerCase();
            columns.add(col);
        }
        return columns;
    }

    public class FilteredDataTableModel {
        @AuraEnabled public List<SObject> data;
        @AuraEnabled public List<Column> columns;
    }

    public class Column {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
    }
}