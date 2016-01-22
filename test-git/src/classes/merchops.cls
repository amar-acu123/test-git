public class merchops{
    public static id invoice(string a, integer b, string c){
        merchandise__c m = [select price__c, total_inventory__c from merchandise__c where name = :a limit 1];
        system.assertnotequals(null,m);
        invoice_statement__c i = new invoice_statement__c(description__c = c);
        insert i;
        line_item__c li = new line_item__c(name = '1',invoice_statement__c=i.id,merchandise__c=m.id,unit_price__c=m.price__c,units_sold__c=b);
        insert li;
        
        m.total_inventory__c -= b;
        update m;
        return i.id;  
    }
    

}