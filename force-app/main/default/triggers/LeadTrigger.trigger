trigger LeadTrigger on Lead (before insert, before update) {

  GeneralSettings__c settings = GeneralSettings__c.getInstance();

  if(settings == null || !settings.DisableAutomation__c) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
          LeadTriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
          LeadTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
  }
}