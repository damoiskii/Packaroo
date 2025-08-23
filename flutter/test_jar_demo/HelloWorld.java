public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello from Packaroo JAR Analyzer!");
        System.out.println("This is a sample application for testing.");
        
        if (args.length > 0) {
            System.out.println("Arguments provided:");
            for (int i = 0; i < args.length; i++) {
                System.out.println("  " + (i+1) + ": " + args[i]);
            }
        }
    }
}
