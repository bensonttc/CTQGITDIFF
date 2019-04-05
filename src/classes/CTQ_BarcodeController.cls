public class CTQ_BarcodeController {
    
    public String recordId {get;set;}
    public PdfConstruct thisPDFConstruct {get;set;}
    public List<PdfConstruct> thisPDFConstructs {get;set;}
    public List<Batch__c> inputBatchRecords;

    public CTQ_BarcodeController(ApexPages.StandardSetController controller){
        system.debug('This is the controller ' + controller);
        if(apexPages.currentPage().getParameters().containsKey('recordId')){
            system.debug('Exec is single');
            this.recordId = apexPages.currentPage().getParameters().get('recordId');
            if(recordId != null || recordId != '') {
                setupPDFParams(recordId);
            } 
        } else {
            if(controller.cancel().getParameters().containsKey('fcf')){
                //List view should only execute on selected records
                inputBatchRecords = controller.getSelected();
            } else { 
                //execute on all records
                if(!controller.getSelected().isEmpty()){
                    inputBatchRecords = controller.getSelected();
                } else {
                    String parentId = ApexPages.currentPage().getParameters().get('id');
                    inputBatchRecords = [Select Id, Name, Scan_Box__c, Barcode__c, Scan_Box__r.Name from Batch__c 
                                        Where Scan_Box__c = :parentId];
                }   
            }
            if(!inputBatchRecords.isEmpty()){
                setupPDFParams(inputBatchRecords);
            }
        }
    }
    
    public void setupPDFParams(String recordId){
        List<Batch__c> batchList = new List<Batch__c>{new Batch__c( id = recordId)};
        setupPDFParams(batchList);
    }  

    public void setupPDFParams(List<Batch__c> inputBatches){
        Set<Id> batchIDs = new Set<Id>();
        for(Batch__c thisBatch: inputBatches){
            batchIDs.add(thisBatch.Id);
        }
        List<Batch__c> relevantBatches = [Select Id, Name, Barcode__c, Scan_Box__r.Name from Batch__c 
                            Where Id IN :batchIDs limit 50];
        thisPDFConstructs = new List<PdfConstruct>();
        String encodedBarcode;  
        for(Batch__c thisBatchRecord : relevantBatches){
            PdfConstruct currentPDFConstruct = new PdfConstruct();
            currentPDFConstruct.success = true;
            currentPDFConstruct.batchRecord = thisBatchRecord;
            if(currentPDFConstruct.batchRecord.Barcode__c != null){
                encodedBarcode = EncodingUtil.urlEncode(currentPDFConstruct.batchRecord.Barcode__c, 'UTF-8');
                currentPDFConstruct.barcodeURL = 'https://barcode.tec-it.com/barcode.ashx?data='+encodedBarcode+'&code=Code39FullASCII&dpi=96&dataseparator=';
            } else {
                currentPDFConstruct.success = false;
                currentPDFConstruct.errorMessage = 'No barcode found';
            }
            thisPDFConstructs.add(currentPDFConstruct);
        }
    }     

    public class PdfConstruct {
        public String barcodeURL {get;set;}
        public Boolean success {get;set;}
        public String errorMessage {get;set;}
        public Batch__c batchRecord {get;set;}
    }
}