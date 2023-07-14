public class sspHelperClassCus {   


    public class OtherWrapperForResult{
        // Wrapper class for return  records,totalRecords and boolean list for disable buttons on aura component........
        @AuraEnabled
        public List<Boolean> disabledList = new List<Boolean>();
        @AuraEnabled
        public List<sObject> records = new List<sObject>();
        @AuraEnabled
        public Integer totalRecords;

        public OtherWrapperForResult(List<Boolean> disabledList,List<sObject> records,Integer totalRecords){
            this.disabledList = disabledList;
            this.records = records;
            this.totalRecords = totalRecords;



            for(sObject sb : records){
                System.debug(sb);
            }

            for(Boolean bb : disabledList){
                System.debug(bb);
            }

            System.debug(totalRecords);
        }
    }



    @AuraEnabled
    public static void getRecords1S(String objectName,List<String> fields,Id recId,Integer pageSize){
        System.debug(objectName +'    '+pageSize+'   '+recId);
        for(String st : fields){
            System.debug(st);
        }
    }


    @AuraEnabled
    public static OtherWrapperForResult getFirstRecords(String objectName,List<String> fields,Integer pageSize,Integer pageNumber){
        
        List<sObject> records = new List<sObject>();
        List<sObject> recordsForSend = new List<sObject>();

        Integer recordLimit = (pageNumber == 1)?1:(pageNumber-1)*pageSize;
        String query1 = 'SELECT ';
        for(Integer i=0;i<fields.size();i++){
            if(i<fields.size()-1){
                query1+=fields[i]+',';
            }else{                
                query1+=(fields[i]+' from '+objectName+' order by id ');
            }
        }  
        System.debug(query1+'   '+recordLimit);
        records = Database.query(query1);

        Integer endPoint = (records.size()-recordLimit>=pageSize)?pageSize:(records.size()-recordLimit);
        System.debug(endPoint);


        Integer j = 0;
        for(Integer i = recordLimit-1;j<=endPoint-recordLimit;i++){
            j++;
            recordsForSend.add(records[i]);
        }

        System.debug(records.size()+'  '+pageSize+'   '+recordsForSend.size());
        Integer totalPages;
        if(Math.mod(records.size(),pageSize)==0){
            totalPages = records.size()/pageSize;
        }else{
            totalPages = Integer.valueOf(Math.floor(records.size()/pageSize)+1);
        }


        //Geting boolena list....
        Boolean prevBool,nextBool;
        List<Boolean> boolList = new List<Boolean>();
        if(pageNumber-1>0){
            prevBool = false;
        }
        else{
            prevBool = true;
        }
        if(pageNumber+1<=totalPages){
            nextBool = false;
        }
        else{
            nextBool = true;
        }
        boolList.add(nextBool);
        boolList.add(prevBool);

        OtherWrapperForResult returnIt = new OtherWrapperForResult(boolList,recordsForSend,totalPages);
        return returnIt;
    }


    @AuraEnabled
    public static List<sObject> sortRecords(List<Id> conId ,List<String> fields,String objectName,String fieldName,String sortDir){
         List<sObject> ct = new List<sObject>();
         System.debug(fieldName);
         String query1 = 'SELECT ';
         for(Integer i=0;i<fields.size();i++){
             if(i<fields.size()-1){
                 query1+=fields[i]+',';
             }else{                
                 query1+=(fields[i]+' from '+objectName);
             }
         }  
         query1+=(' WHERE Id In : conId ORDER BY '+fieldName +' '+sortDir);
         System.debug(query1);
         ct = database.query(query1);
         return ct;
    }
}