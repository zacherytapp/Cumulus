public with sharing class FilteredDataTable_CTRL {

    @AuraEnabled
    public static List<SObject> getData(String sObjectName,
            List<String> fields,
            String recordId,
            String whereClause,
            String childObject,
            String relationshipField) {

        System.debug('CHILD OBJECT:'+ childObject);

        String soql = 'SELECT ' +
                String.join(fields, ', ').removeEnd(', ') +
                ' FROM ' + childObject +
                ' WHERE ' + whereClause.trim() +
                ' AND ' + relationshipField + ' = :recordId';
        System.debug(soql);
        List<SObject> data = Database.query(soql);
        System.debug(data);
        return data;
    }
}