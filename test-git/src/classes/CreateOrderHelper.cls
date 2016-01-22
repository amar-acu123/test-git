/************************************* MODIFICATION LOG ***********************************************************************
* CreateOrderHelper.cls
*
* DESCRIPTION : Class with methods to help create Order
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Public Method Name            Inputs                                  Description
*---------------------------------------------------------------------------------------------------------------------------------------------------
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Amar Setty                    ?      			Create 
*/
public class CreateOrderHelper {
        public static list<string> PaymentTerm = new list<string>{'NET30','NET45','NET60','NET90','NET120','NET180'};
        public static list<string> shippingMethod = new list<string>{'GROUND','USPS'};
        public static list<string> AddressType = new list<string>{'shipping','billing'};
        
		public static ECMStub.customerKey CustomerKeyObject(String eodbId){
			ECMStub.customerKey key = new ECMStub.customerKey();
			key.externalID = eodbId;
			key.namespace = 7;
			return key;
		}        

		public static ECMStub.address AddressObject(){
			ECMStub.address add = new ECMStub.address();
			return add;
		}

		public static ECMStub.contactInfo ContactObject(){
			ECMStub.contactInfo cont = new ECMStub.contactInfo();
			return cont;
		}

		public static ECMStub.productItemKey ProductObject(string s){
			ECMStub.productItemKey p = new ECMStub.productItemKey();
			p.sku = s;
			return p;
		}

		public static ECMStub.defaultPriceAdjustment priceAdjustObject(){
			ECMStub.defaultPriceAdjustment pAdjust = new ECMStub.defaultPriceAdjustment();
			return pAdjust;
		}

		public static ECMStub.price priceObject(double val){
			ECMStub.price p = new ECMStub.price();
			p.value = val;
			return p;
		}

	    public static ECMStub.InstitutionalOrder InstOrderObj(long contactId){
	        ECMStub.InstitutionalOrder instOrder = new ECMStub.InstitutionalOrder();
	        //instOrder.setCdBatchNumber("CdBatchNumber");
	        instOrder.ContactId = contactId;
	        instOrder.PaymentTerm = PaymentTerm[0];
	        instOrder.InvoiceNote = 'ECM junit.ws.';
	        instOrder.PoNumber ='1234321';
	        instOrder.PoAuthAmt = 10000.0;
	        instOrder.CsrUserName = 'junitSalesForce';
	        instOrder.QuoteContractNumber = 'salesforce test';
	        instOrder.SendToFAInd = true;
	        instOrder.InstitutionName = 'Org Name';
	        return instOrder;
	    }

	    public static ECMStub.Shipment ShipmentObject(list<ECMStub.mutableOrderLine> mols, Contact c){
	        
	        ECMStub.shippingMethod sMethod = new ECMStub.shippingMethod();
	        sMethod.flag = 0; // TO-DO need a list of methods and numbers and create a Map ? !!
	        
	        ECMStub.shippingInfo sInfo = new ECMStub.shippingInfo();
	        sInfo.contactInfo = ContactObject();
	        sInfo.shippingAddress = AddressObject();
	        sInfo.shippingMethod = sMethod;
	        sInfo.specialInstructions = 'no instructions';
	        		
	        ECMStub.Shipment shipment = new ECMStub.Shipment();
	        shipment.ShippingInfo = sInfo;
	        shipment.orderLines = new list<ECMStub.mutableOrderLine>();
	        shipment.orderLines.addAll(mols);
	        
	        //shipment.currentTotal
	        //shipment.total
	        //shipment.baseShipping	        
	        //shipment.pricingReply
	
	        return shipment;
	    }

		public static ECMStub.mutableOrder createOrderObject(){
			ECMStub.mutableOrder newOrder = new ECMStub.mutableOrder();

			
			return newOrder;
		}         

		public static void createOrderFromOpp(){
			
			//Opportunity opp = [select account.EODBID__c, (select id, quantity__c, Description,TotalPrice,StartDate__c,EndDate__c,
			//					PricebookEntry.Product2.ProductSKU__c, PricebookEntry.Product2.ProductItemType__c
			//					from OpportunityLineItems) from Opportunity where id = :oppId];
			
			//Contact c = [select ECMAddressId__c, ECMAddresstObject__c, ECMContactId__c, ECMContactObject__c from Contact where id = '0031900000207BS'];					
			Contact c = new Contact();									
			list<ECMStub.mutableOrderLine> mols = new list<ECMStub.mutableOrderLine>();
			list<ECMStub.mutableOrderLine> mols1 = new list<ECMStub.mutableOrderLine>();
			list<ECMStub.orderLine> ols = new list<ECMStub.orderLine>();

			ECMStub.customerKey cusKey = CustomerKeyObject('567');
			
			ECMStub.mutableOrder mOrder = mutableOrderObject(c,cusKey);
			
			OpportunityLineItem oli = new OpportunityLineItem();

			mols.add(mapOliToMol(oli,c));
			
			mols1.add(mapOliToMol(oli,c));
			
			mOrder.orderLines.addAll(mols1);
			
			mOrder.shipments.add(ShipmentObject(mols, c));
			if(mOrder.shipments.size() != 0){
				mOrder.shippingInfo = mOrder.shipments[0].shippingInfo;				
			}
			
			
			system.debug(mOrder.billingAddressId);
			system.debug(mOrder.billingContactId);
			system.debug('>>> number of softgoods'+mOrder.orderLines.size());
			system.debug('>>> number of hardgoods'+mOrder.shipments[0].orderLines.size());
			
			
			
			ECMStub.ECMFacadePort ecmService  = new ECMStub.ECMFacadePort();
			ECMStub.orderInfo res = ecmService.createOrder(cusKey,mOrder,null);
			system.debug(json.serialize(res));
			system.debug(res.Order.Id);
			

		
		
		
		}         
        
		public static ECMStub.mutableOrder mutableOrderObject(Contact c, ECMStub.customerKey key){
			ECMStub.mutableOrder mOrder = new ECMStub.mutableOrder();
			
			mOrder.billingContactId = 1234;
			mOrder.billingAddressId = 123456;
			mOrder.currentTotal = priceObject(5);
			mOrder.customerKey = key;
			mOrder.instOrder = InstOrderObj(123456);
			// mOrder.total = priceObject(10);
			mOrder.orderLines = new list<ECMStub.mutableOrderLine>();
			mOrder.shipments = new list<ECMStub.shipment>();
			mOrder.orderStatus = 'OPEN';
			return mOrder;
		}



		public static ECMStub.mutableOrderLine mapOliToMol(OpportunityLineItem oli, Contact c){
			ECMStub.mutableOrderLine mol = new ECMStub.mutableOrderLine();
			mol.productItemKey = ProductObject('008525');//oli.PricebookEntry.Product2.ProductSKU__c);
			//mol.comments = oli.Description;
			//mol.billingStartDate = oli.StartDate__c;
			//mol.billingEndDate = oli.EndDate__c;
			//mol.description = 'none';
			mol.quantity = 10.0;
			// mol.taxAddress = (ECMStub.address) JSON.deserialize(c.ECMAddresstObject__c,ECMStub.address.class);
			//mol.itemCost = priceObject(5);
			//mol.taxPrice = priceObject(6);
			//mol.unitPrice = priceObject(7);
			//mol.totalLineAmount = oli.TotalPrice;
			//mol.unitPriceAdjustment = priceAdjustObject();
			//mol.status = 'OPEN'; //OrderStatus enum
			return mol;
		}

/*		public static ECMStub.orderLine mapOliToOl(OpportunityLineItem oli, Contact c){

			ECMStub.mutableOrderLine mol = mapOliToMol(oli,c);
			ECMStub.orderLine ol = new ECMStub.orderLine();

			ol.productItemKey 		= mol.productItemKey;
			ol.comments 			= mol.comments;
			ol.billingStartDate 	= mol.billingStartDate;
			ol.billingEndDate 		= mol.billingEndDate;
			ol.description 			= mol.description;
			ol.quantity 			= mol.quantity;
			ol.taxAddress 			= mol.taxAddress;
			ol.itemCost 			= mol.itemCost;
			ol.taxPrice 			= mol.taxPrice;
			ol.unitPrice 			= mol.unitPrice;
			ol.totalLineAmount 		= mol.totalLineAmount;
			ol.unitPriceAdjustment 	= mol.unitPriceAdjustment;
			ol.status 				= mol.status;

			return ol;
		} */

}