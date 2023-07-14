import java.util.Scanner;
public class powerf {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int a = sc.nextInt();
        int b = sc.nextInt();

        int c=1;
        for(int i=0;i<b;i++){
            c= c*a;
        }
        System.out.print(c);
    }
}
