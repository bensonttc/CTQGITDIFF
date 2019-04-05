@isTest
public class CTQ_BarcodeControllerTest {

    public static testMethod void testBarcodeController() {
        //This test needs to be improved by created a Batch__c record.
        //There are other dependant records such as Box, Tour instance, 
        //Account etc that is also needed
        PageReference pageRef = new PageReference('/apex/CTQ_Barcode_PDF');
        Test.setCurrentPage(pageRef);

        Tour_Instance__c theTestTourInstance = TQTestUtils.createTourInstance(
                'TEST_TOUR_INSTANCE1', UserInfo.getUserId(), 'TST', 'STTS3', 
                Date.today().addDays(50), Date.today().addDays(70), false
        );

        Box__c testBox = new Box__c();
        testBox.name = 'Test Box 1';
        insert testBox;

        Batch__c testBatch = new Batch__c();
        //testBatch.name = 'Test Batch 1';
        testBatch.Scan_Box__c = testBox.id;
        testBatch.Tour_Instance__c = theTestTourInstance.id;
        insert testBatch;


        ApexPages.currentPage().getParameters().put('recordId', testBatch.id);
        List<Batch__c> lstBatches = new List<Batch__c>{testBatch};
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstBatches);
        CTQ_BarcodeController controller = new CTQ_BarcodeController(stdSetController);
        //system.assertEquals(controller.recordId,'yyyy');
    }

}