/**
 * @description Active Directory wrapper modals
 */
public class ActiveDirectoryModel {

    /**
     * @description Active Directory Group wrapper
     */
    public class ADGroup {
        public String id; 
        public String name; 
        public String email; 
        public String label;
        public List<String> groupTypes;
        public Boolean isSelected;
        public String groupType;
    }

     /**
     * @description Active Directory Group Member wrapper
     */
    public class ADGroupMember {
        public String id; 
        public String name; 
        public String email;
    }

    /**
     * @description Wrapper class to describe which AD Group Types are selected
     */
    public class SelectedGroupTypes {
        public Boolean isMailGroupsSelected;
        public Boolean isSecurityGroupsSelected;
        public Boolean isMailSecurityGroupsSelected;
        public Boolean isDistributionGroupsSelected;
    }    
    
}