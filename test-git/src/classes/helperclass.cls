public class helperclass{
	public static string asdf = '';
    
    public static void beforeupdate(){
        asdf = 'asdf';
        system.debug('>>>>>>>'+asdf);
    }
    
    public static void afterupdate(){
        system.debug('>>>>>>>>>'+asdf);
        asdf = asdf+'zyxv';
        system.debug('>>>>>>>>>'+asdf);        
    }
}