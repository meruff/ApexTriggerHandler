/**
 * @description Apex unit tests for TriggerSwitch.cls
 */
@IsTest
private class TriggerSwitchTest {
    @IsTest
    static void testTriggerOff() {
        Test.startTest();
        TriggerSwitch triggerSwitch = new TriggerSwitch(Content__c.getSObjectType());
        triggerSwitch.turnOff('Custom_Object__c');
        Test.stopTest();

        System.assertEquals(false, triggerSwitch.isOn('Custom_Object__c'));
    }

    @IsTest
    static void testTriggerOn() {
        Test.startTest();
        TriggerSwitch triggerSwitch = new TriggerSwitch(Content__c.getSObjectType());
        triggerSwitch.turnOn('Custom_Object__c');
        Test.stopTest();

        System.assertEquals(true, triggerSwitch.isOn('Custom_Object__c'));
    }

    @IsTest
    static void testIsOnForCurrentUser() {
        Test.startTest();
        TriggerSwitch triggerSwitch = new TriggerSwitch(Content__c.getSObjectType());
        triggerSwitch.turnOn('Custom_Object__c');
        Test.stopTest();

        System.assertEquals(true, triggerSwitch.isOnForUser('Custom_Object__c'));
    }
}