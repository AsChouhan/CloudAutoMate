@IsTest
private class testClassForPagination {
    @IsTest
    static void testShowFields(){
        globalDesc glInst = new globalDesc();
        glInst.objectName = 'Account';
        glInst.ShowFields();
        System.assertEquals(glInst.dropDownFieldList.size()!=0, true);
    }

    @IsTest
    static void testaddInSelectedList(){
        globalDesc glInst = new globalDesc();
        glInst.objectName = 'Account';
        
        glInst.ShowFields();

        glInst.selectedFieldsList.add('name');    

       
        glInst.addInSelectedList();
        System.assertEquals( glInst.selectedFieldsList.size(),1);
    } 
    

    @IsTest
    static void testremoveFromSelectedFields(){
        globalDesc glInst = new globalDesc();
        glInst.objectName = 'Account';
        glInst.ShowFields();
        glInst.selectedFieldsList.add('name');
        glInst.addInSelectedList();
        glInst.removeFromSelectedFields();

        glInst.deSelectedFieldsList.add('name');
        glInst.removeFromSelectedFields();
        System.assertEquals(1, glInst.deSelectedFieldsList.size());
        System.assertEquals(0, glInst.dropDownSelectedFieldList.size());
    }  

   
    @IsTest
    static void testReset(){
        globalDesc glInst = new globalDesc();
        glInst.objectName = 'Account';
        glInst.ShowFields();
        
        System.assertEquals(glInst.dropDownFieldList.size()!=0,true);

        glInst.Reset();
        System.assertEquals(glInst.dropDownFieldList.size()!=0,false);
    }

    @IsTest
    static void testProcessrecord(){
        globalDesc glInst = new globalDesc();
        glInst.objectName = 'Account';
        glInst.ShowFields();

        String kp = '001';

        glInst.Processrecord();
        String orgKp = glInst.gd.get(glInst.objectName).getDescribe().getKeyPrefix();
        System.assertEquals(kp == orgKp,true);
    }
}