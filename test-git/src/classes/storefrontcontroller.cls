public class storefrontcontroller{
 list<displaymerchandise> products;
 list<displaymerchandise> shoppingcart = new list<displaymerchandise>();
    
    public pagereference addtocart(){
        for(displaymerchandise p:products){
            if(0<p.qtytobuy){shoppingcart.add(p);}}
        return null;}
    
    public string getcartcontents(){
        if(0==shoppingcart.size()){return '(empty)';}
        string msg = '<ul>\n';
        for(displaymerchandise p:shoppingcart){
            msg += '<li>';
            msg += p.name+' ('+p.qtytobuy + ') ';
            msg += '</li>\n';
        }
        msg += '<ul>';
        return msg;
    }


    public list<displaymerchandise> getproducts(){
        if (products == null) {
            products = new list<displaymerchandise>();
            for(merchandise__c item:[select id, name, description__c, price__c, total_inventory__c from merchandise__c]){
                  products.add(new displaymerchandise(item));
    }
    }
    return products;

    }
        public class displaymerchandise {
        
        private merchandise__c merchandise;
            public displaymerchandise(merchandise__c item){
                this.merchandise = item;
            }
            
            public string name{
                get {return merchandise.name;}
            }
            public string Description{
                get {return merchandise.Description__c;}
            }
            public decimal price{
                get {return merchandise.Price__c;}
            }
            public boolean instock{
                get {return (0<merchandise.Total_Inventory__c);}
            }
            public integer qtytobuy{get; set;}
        }    
    }