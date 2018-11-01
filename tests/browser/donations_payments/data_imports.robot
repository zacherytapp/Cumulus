*** Settings ***

Resource        tests/NPSP.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Data Imports
    ${first_name1} =           Generate Random String
    ${last_name1} =            Generate Random String
    ${acc1}=                   Generate Random String 
    ${first_name2} =           Generate Random String
    ${last_name2} =            Generate Random String
    ${acc2}=                   Generate Random String
    Sleep    5
    Open App Launcher
    Populate Address    Search apps or items...    NPSP Data Imports
    Select App Launcher Link  NPSP Data Imports
    Click Object Button       New
    Populate Form
    ...                       Contact1 First Name=${first_name1}
    ...                       Contact1 Last Name=${last_name1}
    ...                       Account1 Name=${acc1}
    ...                       Contact2 First Name=${first_name2}
    ...                       Contact2 Last Name=${last_name2}
    ...                       Account2 Name=${acc2}
    Click Modal Button        Save
    Go To Object Home         npsp__DataImport__c
    Select Object Dropdown
    Click Link    link=All
    #Sleep    2
    #Click Link    link=Status
    Click Special Object Button       Start Data Import
    #Sleep    3
    Select Frame With Title   NPSP Data Import
    Click Button With Value   Begin Data Import Process
    Wait For Locator    data_imports.status    Completed
    
    
        