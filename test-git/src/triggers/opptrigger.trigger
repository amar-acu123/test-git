trigger opptrigger on Opportunity (before update, after update, before delete, after delete) {

    list<Opportunity> oppList = new list<Opportunity>();
    oppList = [select id, type from Opportunity where id in :trigger.oldMap.keyset()];
    if(trigger.isBefore && trigger.isUpdate){
        helperclass.beforeupdate();
    }
    if(trigger.isAfter && trigger.isUpdate){
        helperclass.afterupdate();
    }

}