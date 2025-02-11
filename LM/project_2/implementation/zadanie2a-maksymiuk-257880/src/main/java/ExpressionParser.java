import java.util.Scanner;
import java.util.regex.Pattern;

/**
 * @author Maciej Maksymiuk
 */
public class ExpressionParser {
	
	private static final String REGEX = "^[0-9]+([+\\-*/^][0-9]+)+([+\\-*/^][0-9]+)*(;[0-9]+[+\\-*/^][0-9]+" +
			"([+\\-*/^][0-9]+)*)*$";
	
	public static void main(String[] args) {
		Scanner scanner = new Scanner(System.in);
		
		System.out.println("Podaj wyrażenie arytmetyczne do sprawdzenia:");
		String input = scanner.nextLine().trim();
		
		if (isValidExpression(input)) {
			System.out.println("Wyrażenie jest zgodne z gramatyką.");
		} else {
			System.out.println("Wyrażenie nie jest zgodne z gramatyką.");
		}
		
	}
	
	private static boolean isValidExpression(String expression) {
		return Pattern.matches(REGEX, expression);
	}
	
}
