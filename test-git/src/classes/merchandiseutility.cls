public class merchandiseutility{
    public static void mainprocessing(){
        try{
            insertmerchandise();
        } catch (merchandiseexception me) {
            system.debug('message '+ me.getmessage());
            system.debug('cause '+ me.getcause());
            system.debug('line number '+ me.getlinenumber());
            system.debug('stack trace '+ me.getstacktracestring());
        }
    }
     public static void insertmerchandise() {
         try{
             merchandise__c m = new merchandise__c();
             insert m;
         } catch(dmlexception e) {
             throw new merchandiseexception('asdf ', e);
         }
     }
                   
}