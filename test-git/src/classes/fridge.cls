public class fridge implements kitchenutility{
     string modelnumber;
     integer numberinstock;
    
    public void updatestock(integer i) {
        numberinstock = numberinstock - i ;
    }
    
    public void setmodelnumber(string s) {
        modelnumber = s;
    }
    
    public string getmodelnumber() {
        return modelnumber;
    }
    
    public fridge () {
        modelnumber = 'x-x';
        numberinstock = 0;
    }
    
    public fridge(string s, integer i) {
        modelnumber = s;
        numberinstock = i;
    }
    
    public static integer stockthreshold = 5;
    
    public static final integer stock_th = 8;   
    
    public static void todebug(fridge afridge) {
        system.debug('modelnumber = ' + afridge.modelnumber);
        system.debug('number in stock = ' + afridge.numberinstock);
    }
    
    public integer ecorating {
        get {return ecorating;}
        set { ecorating = value; if (ecorating < 0) ecorating = 0;}
    }
            
            
            
            
            
            
            
            
            
            
            
            
    
    
}