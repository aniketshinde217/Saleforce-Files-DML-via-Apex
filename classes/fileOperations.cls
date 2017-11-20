public class fileOperations
{
    Blob fileBody;
    String fileName;
    StaticResource staticRec, staticRecNew;
    contact con;
    Id ContentDocId;
    public String logs
    {get;set;}
    
    
    public fileOperations()
    {
        List<StaticResource> lstStaticRes = [select name, body, contentType from staticResource where name IN ('my_data','my_data_new')];
		for(StaticResource sr : lstStaticRes)
        {
            if(sr.name == 'my_data')
                staticRec = sr;
            else if(sr.name == 'my_data_new')
                staticRecNew = sr;
        }    
        addLogs('Controller Loaded  [Queried Static Resources For Body, Name of File]');
    }
    
    private void addLogs(String msg)
    {
        if(logs == null)
        {
            logs = '';
        }   
        logs = logs + '<br/><br/>  >   ' + msg;   
    }
    
    private void init()
    {
        if(staticRec != null)
        {
            con = new Contact();
            con.firstName = 'Mr. File';
            con.LastName = 'Demo';
            try{
                insert con;
            }
            catch(Exception e)
            {
             	System.debug(' ** Contact Insertion Failed !! Exception : '+e.getMessage());   
            }  
            if(con.Id != null)
            {    
	            addLogs('init [ Images Loaded from Static Resources.. Contact Created <'+con.Id+'>]');
            }    
        }
    }
    
    private void createFile()
    {
        ContentVersion contVer = new contentVersion();
        contVer.versionData = staticRec.body;
        if(staticRec.contentType == 'image/jpeg')
        	contVer.pathOnClient = staticRec.name+'.jpg';
        else
            contVer.pathOnClient = staticRec.name;
        contVer.title = staticRec.name;
        contVer.Origin = 'C';
        try{
            insert contVer;
            ContentDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contVer.Id].ContentDocumentId;
        }
        catch(Exception e)
        {
            System.debug(' ** contVer Insertion Failed !! Exception : '+e.getMessage());   
        }  
        if(ContentDocId != null)
        {    
            addLogs('File Created [Content Document Created <'+ContentDocId+'>]');
        }            
    }
    private void linkFileToContact()
    {
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = ContentDocId;
        cdl.LinkedEntityId = con.Id;
        cdl.ShareType = 'V';
        try{
        	insert cdl;
        }
        catch(Exception e)
        {
            System.debug(' ** ContentDocumentLink Insertion Failed !! Exception : '+e.getMessage());   
        }    
        if(cdl.Id != null)
        {    
        	addLogs('File Linked [Content Document Link Created, To Link Contact <'+con.Id+'> and File <'+ContentDocId+'> ]'); 
        }            
    }  
                    
    private void updateFile()    
    {
        ContentVersion cont = new ContentVersion();
        cont.ContentDocumentId = ContentDocId;
        cont.Title = staticRecNew.name;
        if(staticRecNew.contentType == 'image/jpeg')
        	cont.pathOnClient = staticRecNew.name+'.jpg';
        else
            cont.pathOnClient = staticRecNew.name;
        cont.VersionData = staticRecNew.body;
        try
        {
        	insert cont;
        }
        catch(Exception e)
        {
            System.debug(' ** New ContentVersion Insertion Failed !! Exception : '+e.getMessage()); 
        } 
        if(cont.id != null)    
        	addLogs('File Updated [Added New Content Version to File <'+ContentDocId+'>]');
    }
    private void queryLatestVersion()
    {
        ContentDocument contDoc = [select LatestPublishedVersionId from contentDocument where id = :ContentDocId];
		ContentVersion contVer = [select Title, PathOnClient, VersionData from ContentVersion where Id = :contDoc.LatestPublishedVersionId];
        addLogs('File\'s Latest Version Queried <'+contVer.Title+'>');
    }    
    private void deleteFile()
    {
        ContentDocument contDoc = new ContentDocument();
		contDoc.Id = ContentDocId;
        try{
			delete contDoc;
            delete con;
            addLogs('File <'+contDoc.Id+'> AND Contact <'+con.Id+'> Deleted');
        }
        catch(Exception e)
        {
            System.debug(' ** File Delete Operation Failed !! Exception : '+e.getMessage());
        }    
    }    
        
    public void performProceed()
    {
        if(logs.contains('Deleted'))
        {
            addLogs('Bingo! We are done with DEMO!!');
        }
        else if(logs.contains('Latest Version Queried'))
        {
            deleteFile();
        }
        else if(logs.contains('File Updated'))
        {
            queryLatestVersion();
        }
        else if(logs.contains('File Linked'))
        {
            updateFile();
        }
        else if(logs.contains('File Created'))
        {
            linkFileToContact();
        }
        else if(logs.contains('init'))
        {
            createFile();
        }
        else if(logs.contains('Controller Loaded'))
        {
            init();
        }
        else
        {
            addLogs('Unknown Operation');
        }    
    }
}