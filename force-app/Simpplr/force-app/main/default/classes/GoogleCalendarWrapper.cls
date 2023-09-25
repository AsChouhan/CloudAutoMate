public with sharing class GoogleCalendarWrapper {
    public class EventsResponseWrpper {
        public String timeZone;
        public String accessRole;
        public String nextPageToken;
		public List<EventWrapper> items;
    }

    public class EventWrapper {
		public String id;
		public String status;
		public String htmlLink;
		public String summary;
		public String description;
		public String location;
		public DateTimeWrapper start;
		public DateTimeWrapper end_z;
        public String iCalUID;
        public CreatorWrapper creator;
        public DateTime created;
        public DateTime updated;
        public String visibility;
    }
    public class DateTimeWrapper {
        public Date date_z;
        public DateTime dateTime_z;
        public String timeZone;
    }
    public class CreatorWrapper {
        public String email;
        public String displayName;
    }

    public class CalendarResponseWrpper {
        public List<CalendarWrapper> items;
    }

    public class CalendarWrapper {
        public String id;
        public String summary;
    }

    public static EventsResponseWrpper parseEventsResponseWrpper(String json){
        return (EventsResponseWrpper) System.JSON.deserialize(json.replaceAll('"end":', '"end_z":')
                                                                    .replaceAll('"dateTime":', '"dateTime_z":')
                                                                    .replaceAll('"date":', '"date_z":'), EventsResponseWrpper.class);
	}
}