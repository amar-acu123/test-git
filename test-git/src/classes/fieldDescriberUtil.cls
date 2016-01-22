/*
 * Jon LAL; April 23, 2014; 
 * Utility class to describe fields for the Data Dictionary update
 * This will wipe and re-fill the SObjectField__c with records of 
 * the field information in the objectTypes List
 */
 
public without sharing class fieldDescriberUtil{

    
    public static boolean DO_PICKLISTS = true;

    public static void Describer(){



        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        
        ACU_Object__c[] objList = doObjects ( gd );
        ACU_Field__c[] fieldList = doFields ( gd , objList);


           
    }


    public static ACU_Object__c[] doObjects( Map<String,Schema.SObjectType> gd ) {  

        // What is already tracked : objects //
        List<ACU_Object__c> existing_o = [Select Id, Name, API_Name__c, Label__c, isCustom__c , isCustomSetting__c ,KeyPrefix__c From ACU_Object__c Where isDeleted__c = false];
        Map<String,ACU_Object__c> existing_o_map = new Map<String,ACU_Object__c> ();
        for (ACU_Object__c x_o : existing_o ){
            existing_o_map.put(x_o.API_Name__c, x_o);
            
        }        

        ACU_Object__c[] objList = new ACU_Object__c[]{};
        ACU_Object__c[] objUpsert = new ACU_Object__c[]{};

        for(Schema.SObjectType gdv : gd.Values() ){
            Schema.DescribeSObjectResult dsor = gdv.getDescribe();
            String objectName = dsor.getName();
            
            
            // Exclude all the unwanted Sobjects e.g. History, Share etc..
            if(  !objectName.endsWithIgnoreCase('history') 
                 && !objectName.endsWithIgnoreCase('tag')
                 && !objectName.endsWithIgnoreCase('share') 
                 && !objectName.endsWithIgnoreCase('feed')
                 && !objectName.startsWithIgnoreCase('acu_')
                 && !objectName.startsWithIgnoreCase('apex')
                 && !objectName.startsWithIgnoreCase('setupentityaccess')
                 && !objectName.startsWithIgnoreCase('matchingruleitem')
                  ){      
            
                ACU_Object__c acu_o = new ACU_Object__c();
                acu_o.Name = objectName;
                acu_o.API_Name__c = objectName;
                acu_o.Label__c = dsor.getLabel();
                acu_o.isCustom__c = dsor.isCustom();
                acu_o.isCustomSetting__c = dsor.isCustomSetting();
                acu_o.KeyPrefix__c = dsor.getKeyPrefix();
                acu_o.isDeleted__c = false;
                objList.add(acu_o);

                // check for similarities 
                if (existing_o_map.get(objectName) == null ||
                    existing_o_map.get(objectName).Label__c != acu_o.Label__c ||
                    existing_o_map.get(objectName).KeyPrefix__c != acu_o.KeyPrefix__c ||
                    existing_o_map.get(objectName).isCustomSetting__c != acu_o.iscustomSetting__c ){
                     objUpsert.add(acu_o);
                } 

                existing_o_map.remove(objectName);
            }
        }
        if ( existing_o_map.size() > 0)
        {
            for ( ACU_Object__c objToDel : existing_o_map.values() ) {
                objToDel.isDeleted__C = true;
                objUpsert.add(objToDel);
            }
        }

        system.debug(LoggingLevel.INFO,'upsert ObjectList size:' + objUpsert.size() );
        if (objUpsert.size() > 0 ){
            upsert objUpsert API_Name__c;
        }
        return objList;       
    }
        
    
    public static ACU_Field__c[] doFields( Map<String,Schema.SObjectType> gd, List<ACU_Object__c> objList  ){


        Map<String , ACU_Field__c> existingFieldMap = new Map<String , ACU_Field__c>();
        Map<String , ACU_Field__c> currentFieldMap = new Map<String , ACU_Field__c>();

        Set<String> fieldsToDelete = new Set<String>{};
        for (ACU_Field__c f : [Select Name,   
                                      API_Name__c,
                                      Digits__c,
                                      isCaseSensitive__c,
                                      isCustom__c,
                                      isDeleted__c, 
                                      isExternalID__c,  
                                      Label__c,
                                      Length__c, 
                                      Object_Field__c, 
                                      Object__c,
                                      Precision__c,
                                      Scale__c,
                                      Type__c                                    
                                      From ACU_Field__c WHERE isDeleted__c = false] ){
            existingFieldMap.put(f.Object_Field__c, f);
            fieldsToDelete.add(f.Object_Field__c);
        }


        Map<String , ACU_Picklist__c> picklistMap = new Map<String , ACU_Picklist__c>();


        Map<String,ACU_Picklist__c> plvDeletes = new Map<String, ACU_Picklist__c>();
        Set<String> existing_plv = new Set<String>{};
        for ( ACU_Picklist__c plvd : [Select Id , Name , Object_Field_Picklist__c From ACU_Picklist__c Where isDeleted = false] ){
            plvDeletes.put(plvd.Object_Field_Picklist__c, plvd);
            existing_plv.add(plvd.Object_Field_Picklist__c);
        }

        for ( ACU_Object__c obj : objList ){

            Schema.DescribeSObjectResult dsor =  gd.get(obj.API_Name__c).getDescribe(); 
            Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();


            ACU_Object__c object_r = new ACU_Object__c(API_Name__c = obj.API_Name__c);
            
            for (String field : objectFields.keyset() ) {

          
                Schema.DescribeFieldResult dfr = objectFields.get(field).getDescribe();

                ACU_Field__c f = new ACU_Field__c();
                
                f.Name =  dfr.getName();
                f.API_Name__c = dfr.getName();
                if ( dfr.getType().Name() == 'INTEGER' ){
                    f.Digits__c = dfr.getDigits();
                }

                f.isCaseSensitive__c = dfr.isCaseSensitive();
                f.isCustom__c = dfr.isCustom();
                f.isDeleted__c = false;
                f.isExternalID__c = dfr.isExternalID() ;
                f.Label__c = dfr.getLabel();

                   
                if(dfr.getType().Name() == 'STRING'){
                    f.Length__c = dfr.getLength();
                }

                f.Object_Field__c = obj.API_Name__c + ':' + dfr.getName();                
                f.Object__r = object_r; 

                if ( dfr.getType().Name() == 'NUMBER' ){
                    f.Precision__c = dfr.getPrecision();
                }

                if ( dfr.getType().Name() == 'NUMBER' ){
                    f.Scale__c = dfr.getScale();
                }


                f.Type__c = dfr.getType().Name();
                
                if( dfr.getDefaultValueFormula() != null ){
                    f.defaultValueFormula__c = dfr.getDefaultValueFormula();
                }

                            
                if (dfr.getCalculatedFormula() != null) {
                    f.CalculatedFormula__c = dfr.getCalculatedFormula() ;
                }

                // PLV - start //
                if (f.Type__c == 'PICKLIST'){   
                    ACU_Field__c field_r = new ACU_Field__c(Object_Field__c = f.Object_Field__c );
                    List<Schema.PicklistEntry> plvs = dfr.getPicklistValues();
                    for (Schema.PicklistEntry plv : plvs ){

                        ACU_Picklist__c p = new ACU_Picklist__c();
                        p.Field__r = field_r;
                        p.Name = plv.getValue();
                        p.isDeleted__c = false;
                        p.Object_Field_Picklist__c = f.Object_Field__c + ':' + p.Name;

                        if (!existing_plv.contains(p.Object_Field_Picklist__c) &&  picklistMap.size() < 5000){
                            picklistMap.put(p.Object_Field_Picklist__c, p );
                        } 
                        plvDeletes.remove(p.Object_Field_Picklist__c);
                    }

                }
                // PLV - end //

                if (  existingFieldMap.get(f.Object_Field__c) == null ||
                     f.Name != existingFieldMap.get(f.Object_Field__c).Name ||
                     f.Label__c != existingFieldMap.get(f.Object_Field__c).Label__c ||
                     f.Type__c != existingFieldMap.get(f.Object_Field__c).Type__c ||
                     f.Digits__c != existingFieldMap.get(f.Object_Field__c).Digits__c ||
                     f.Precision__c != existingFieldMap.get(f.Object_Field__c).Precision__c ||
                     f.Scale__c != existingFieldMap.get(f.Object_Field__c).Scale__c ||
                     f.isCaseSensitive__c != existingFieldMap.get(f.Object_Field__c).isCaseSensitive__c ||
                     f.isExternalID__c != existingFieldMap.get(f.Object_Field__c).isExternalID__c ) {
                    currentFieldMap.put(f.Object_Field__c , f );
                }

                fieldsToDelete.remove(f.Object_Field__c);
            }
        }

        for (String fieldName : fieldsToDelete){
            existingFieldMap.get(fieldName).isDeleted__c = true;
            currentFieldMap.put(existingFieldMap.get(fieldName).Object_Field__c, existingFieldMap.get(fieldName));
        }


        ACU_Field__c[] currentFieldList = new ACU_Field__c[]{};
        for( ACU_Field__c f : currentFieldMap.values() ){
            currentFieldList.add(f);
        }

        system.debug(LoggingLevel.INFO, 'upsert currentFieldList size: ' + currentFieldList.size() );
        upsert currentFieldList Object_Field__c;


        // PLV - start //
        for ( ACU_Picklist__c plvToDel : plvDeletes.values() ){
            plvToDel.isDeleted__c = true;
            picklistMap.put(plvToDel.Object_Field_Picklist__c , plvToDel);
        }

        ACU_Picklist__c[] picklistList = new ACU_Picklist__c[]{};
        for ( ACU_Picklist__c p : picklistMap.values() ){
            picklistList.add(p);
        }

        system.debug(LoggingLevel.INFO, 'upsert picklistList size: ' + picklistList.size() );
        upsert picklistList Object_Field_Picklist__c;

        
        // PLV - end //





        return currentFieldList;
    }
}