/**
 * @description A helper class to check if triggers are on / off. This class only reads from the metadata for the
 * supplied SObjectType and class name to determine if they are turned off.
 *
 * @see Triggers for implementation.
 *
 * @author Mat Ruff | mat.ruff@builtin.com
 *
 * @date 1/6/23
 */
public without sharing class TriggerSwitch {
    private final Map<String, Boolean> onOffMap;
    private final SObjectType sObjectType;
    private final String sObjectName;

    private final Map<String, Trigger_Switch__mdt> triggerSwitchConfigMap {
        get {
            if (triggerSwitchConfigMap == null) {
                triggerSwitchConfigMap = new Map<String, Trigger_Switch__mdt>();

                for (Trigger_Switch__mdt triggerSwitch : [
                    SELECT Id,
                        Context_Name__c,
                        Is_Active__c,
                        User_Emails_to_Skip__c
                    FROM Trigger_Switch__mdt
                ]) {
                    triggerSwitchConfigMap.put(triggerSwitch.Context_Name__c, triggerSwitch);
                }
            }

            return triggerSwitchConfigMap;
        }

        set;
    }

    public TriggerSwitch(SObjectType sObjectType) {
        this.sObjectType = sObjectType;
        this.sObjectName = sObjectType?.getDescribe()?.getName();
        this.onOffMap = initOnOffMap();
    }

    /**
     * @description Builds a new Map from custom metadata values to determine if a handler or entire SObject trigger
     * is turned on or off.
     *
     * @return a Map of Boolean values representing on/off state keyed by the SObject name or handler class name.
     */
    private Map<String, Boolean> initOnOffMap() {
        Map<String, Boolean> onOffMap = new Map<String, Boolean>();

        for (Trigger_Switch__mdt triggerSwitch : this.triggerSwitchConfigMap.values()) {
            onOffMap.put(triggerSwitch.Context_Name__c, triggerSwitch.Is_Active__c);
        }

        return onOffMap;
    }

    /**
     * @description Checks custom metadata to see if a given trigger handler or SObjectType is turned on. Defaults
     * to "on" if there is no metadata found for the given context.
     *
     * @param sObjOrClass a String representing the name of the handler running i.e. "ContentValidationHandler".
     *
     * @return a Boolean representing whether or not the trigger handler (or Object level) is turned on.
     */
    public Boolean isOn(String sObjOrClass) {
        if (!this.onOffMap.containsKey(sObjOrClass)) {
            return true;
        }

        if (String.isNotBlank(this.triggerSwitchConfigMap?.get(sObjOrClass)?.User_Emails_to_Skip__c)) {
            return isOnForUser(sObjOrClass);
        }

        return this.onOffMap.get(sObjOrClass);
    }

    /**
     * @description Checks custom metadata to see if a given trigger handler or SObjectType is turned on for the
     * current running User.
     *
     * @param sObjOrClass a String representing the name of the handler running i.e. "ContentValidationHandler".
     *
     * @return a Boolean representing whether or not the trigger handler (or Object level) is turned on for the
     * current running User.
     */
    @TestVisible
    private Boolean isOnForUser(String sObjOrClass) {
        if (String.isBlank(this.triggerSwitchConfigMap?.get(sObjOrClass)?.User_Emails_to_Skip__c)) {
            return true;
        }

        return this.triggerSwitchConfigMap.get(sObjOrClass).User_Emails_to_Skip__c
            .split(';')
            .contains(UserInfo.getUserEmail());
    }

    /**
     * @description Allows a dev to turn on triggers for an SObject or handler.
     *
     * @param sObjOrClass the String name of the SObject of handler (i.e. Content__c or ContentValidationHandler).
     */
    public void turnOn(String sObjOrClass) {
        this.onOffMap.put(sObjOrClass, true);
    }

    /**
     * @description Allows a dev to turn off triggers for an SObject or handler. Specifically useful for
     * turning whole SObjects off.
     *
     * @param sObjOrClass the String name of the SObject of handler (i.e. Content__c or ContentValidationHandler).
     */
    public void turnOff(String sObjOrClass) {
        this.onOffMap.put(sObjOrClass, false);
    }
}