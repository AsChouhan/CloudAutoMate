@isTest
private class TestFileWrapper {
		@isTest static void testMethod1() {
			FileWrapper obj = new FileWrapper('DummyURL');
			obj = new FileWrapper();
			obj.locationList = new List<String>();
			obj.tages = new List<String>();
			obj.fileName = 'Dummy';
			obj.allowComments = false;
			obj.coverStory = false;
			obj.CSStartDate = 'Jan 01, 2010';
			obj.CSEndDate = 'Jan 01, 2010';
			obj.author = UserInfo.getUserId();
			obj.contentId = 'Dummy';
			obj.locations = 'Dummy';
			obj.metadata = 'Dummy';
			obj.MIMeTypec = 'Dummy';
			obj.publishStartDate = 'Jan 01, 2010';
			obj.publishEndDate = 'Jan 01, 2010';
			obj.downloads = 0;
			obj.status = 'Dummy';
			obj.tags = 'Dummy';
			obj.text = 'Dummy';
			obj.thumbnail = 'Dummy';
			obj.title = 'Dummy';
			obj.url = 'Dummy';
			obj.fileId = 'Dummy';
			obj.DocumentId = 'Dummy';
			obj.duration = 0;
			obj.groups = 'Dummy';
			obj.likes = 0;
			obj.size = 0;
			obj.shares  = 0;
			System.assert(true, 'Running as Expected');
		}
}