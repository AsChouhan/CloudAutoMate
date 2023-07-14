@IsTest
Private class ComponentControllerTestClass {
    @IsTest
    static void testShowe(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        System.assert(pccInst.objectFields.size() == pccInst.tempFieldsSelectoptionLisst.size(),true);
    }

    @IsTest
    static void testcreateDownloadCsvstring(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        for(pagComponentController.wrapper wee : pccInst.wrapperList){
            wee.Wrapperbool = true;            
        }
        pccInst.createDownloadCsvstring();
    }

    @IsTest
    static void testsortByTag(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        pccInst.fieldForSort = 'Name';
        String tempStr = 'select name from '+pccInst.ObjectNameForQuery+' order by '+pccInst.fieldForSort;
        List<sObject> ct = new List<sObject>();
        ct = Database.query(tempStr);
        pccInst.sortByTag();
        System.debug(pccInst.sCon.getResultSize());
        System.assertEquals(pccInst.sCon.getResultSize() == ct.size(), true);
    }


    @IsTest
    static void testdeleteRec(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        Integer beforeLen = acct.size();
        pccInst.idForEditDelete = acct[0].Id;
        
        pccInst.deleteRec();
        acct.clear();
        string str = 'select name from '+pccInst.ObjectNameForQuery;
        acct = Database.query(str);
        Integer afterLen = acct.size();
        System.debug(afterLen+'  '+beforeLen);
        System.assertEquals(beforeLen!=afterLen, true);
    }

    @IsTest 
    static void testdel(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        Integer beforelen = pccInst.sCon.getResultSize();
        Integer i =0;
        System.debug(pccInst.wrapperList.size());
        for(pagComponentController.wrapper wee : pccInst.wrapperList){
            if(i<3){
                wee.Wrapperbool = true;  
            }else{
                break;
            }
        }
        pccInst.del();
        Integer afterLen = pccInst.sCon.getResultSize();
       
        System.assertEquals(afterLen!=beforelen, true);
    }

    @IsTest
    static void testcharFilter(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        pccInst.alphabate = 't';
        String qur = 'select name from '+pccInst.ObjectNameForQuery+' where name like \''+pccInst.alphabate+'%\'';
        List<SObject> obj = new List<sObject>();
        obj = Database.query(qur);
        pccInst.charFilter();
        System.assertEquals(pccInst.sCon.getResultSize() == obj.size(), true);
    }

    @IsTest
    static void testNext(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        List<sObject> ob1 = pccInst.sCon.getRecords();
        pccInst.Next();
        List<sObject> ob2 = pccInst.sCon.getRecords();
        Boolean bool = System.equals(ob1, ob2);
        System.assertEquals(bool, false);
    }

    @IsTest
    static void testPrevious(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        List<sObject> ob1 = pccInst.sCon.getRecords();
            pccInst.Previous();
            List<sObject> ob2 = pccInst.sCon.getRecords();
            Boolean bool = System.equals(ob1, ob2);
        if(pccInst.sCon.getHasPrevious()){
            System.assertEquals(bool, false);
        }else{
            System.assertEquals(bool, true);
        }
    }

    @IsTest
    static void testFirst(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        List<sObject> ob1 = pccInst.sCon.getRecords();
        pccInst.First();
        List<sObject> ob2 = pccInst.sCon.getRecords();
        Boolean bool = System.equals(ob1, ob2);
        System.assertEquals(bool, true);
    }

    @IsTest
    static void testLast(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        List<sObject> ob1 = pccInst.sCon.getRecords();
        pccInst.last();
        List<sObject> ob2 = pccInst.sCon.getRecords();
        Boolean bool = System.equals(ob1, ob2);
        System.assertEquals(bool, false);
    }

    @IsTest
    static void testsetPageSiz(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        List<SObject> ob1 = pccInst.sCon.getRecords();
        pccInst.size = 15;
        pccInst.setPageSiz();
        List<SObject> ob2 = pccInst.sCon.getRecords();
        System.assertEquals(ob1.size()!=ob2.size(), true);
    }

    @IsTest
    static void testeditRec(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        pccInst.idForEditDelete = acct[0].Id;
        pccInst.editRec();
    }

    @IsTest
    static void testnewRecord(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        pccInst.keyPrefixOfObject = '001';
        pccInst.newRecord();
    }

    @IsTest
    static void testgoToPage(){
        List<Account> acct = GanreateRecForTest.AccountRecords();
        pagComponentController pccInst = new pagComponentController();
        pccInst.ObjectNameForQuery = 'Account';
        pccInst.objectFields.add(new SelectOption('Name','Account Name'));
        pccInst.objectFields.add(new SelectOption('Rating','Account Rating'));
        pccInst.showe();
        pccInst.NewPageNumber = 2;
        pccInst.goToPage();
    }


}