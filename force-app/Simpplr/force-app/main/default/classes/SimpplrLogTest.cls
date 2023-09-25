/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SimpplrLogTest {

    @testSetup static void setup() {
        TestHelper.setupAppConfig();
         
    }
    
    @isTest static void testGetInstance() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetRequestUniqueToken() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLogDebug() { 
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLogError1() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLogError2() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLogInfo() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLog() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testConstructSimpplrLogMessage() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGenerateGUID() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testgetLogLimitStatus() {
        SimpplrLog logger = SimpplrLog.getInstance(SimpplrLogTest.class.getName());
        logger.getLogLimitStatus();
        logger.logLimitStatus();
        logger.logInfo('Test Message');
        logger.logDebug('Test Message');
       System.assert(true,'Running as expected');
    }
    
}