public class RecursionCheck {
    public static Boolean shouldIRun = true;
    public static Boolean canIRun() {
        return shouldIRun;
    }
    
    public static void stopRecursion() {
        shouldIRun = false;
    }

    public static void allowToRun() {
        shouldIRun = true;
    }
}