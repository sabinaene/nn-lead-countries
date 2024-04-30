trigger CountryTrigger on Country__c (after insert, after update, after delete, after undelete) {

  GeneralSettings__c settings = GeneralSettings__c.getInstance();

  if(settings == null || !settings.DisableAutomation__c) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
          CountryTriggerHandler.afterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
          CountryTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
          CountryTriggerHandler.afterDelete(Trigger.old);
        } 
        when AFTER_UNDELETE {
          CountryTriggerHandler.afterUndelete(Trigger.new);
        }
    }
  }
}