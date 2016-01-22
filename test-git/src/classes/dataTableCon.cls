public class dataTableCon {

    List<Account> accounts;
    
    integer ae;
    public boolean noneselected {set;get;}
    public boolean cpanel {set;get;}
    
    
    public integer getae() {
     return 10;
    }

    public List<Account> getAccounts() {

        if(accounts == null) accounts = [select name, NumberOfEmployees, AnnualRevenue from account];
        cpanel = true;
        return accounts;

    }
    
    public PageReference validateapplication() {
     cpanel = false;
     return null;
     }
    public void submitapplication() {}

}