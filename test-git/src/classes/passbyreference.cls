public class passbyreference {

    public static void mainmethod(){
    Account a = new Account();
    a.name = 'asdfasdfasdf';
    
    insertaccount(a);  
    system.debug(a.id);
    }
    
    public static void insertaccount(account asdf){
        insert asdf;
    }
}