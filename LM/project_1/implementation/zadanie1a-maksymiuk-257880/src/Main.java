import java.util.Scanner;

/**
 * Klasa główna programu symulującego automat do pobierania opłat w myjni samochodowej.
 *
 * @author Maciej Maksymiuk
 */
public class Main {

    /**
     * Metoda główna programu.
     * Obsługuje interakcję z użytkownikiem i proces wrzucania monet.
     *
     * @param args argumenty wiersza poleceń (nieużywane)
     */
    public static void main(String[] args) {
        // Utworzenie instancji automatu
        CarWashDFA carWashDFA = new CarWashDFA();

        // Wyświetlenie tablicy przejść
        carWashDFA.displayTransitionTable();

        // Inicjalizacja skanera do odczytu danych od użytkownika
        Scanner scanner = new Scanner(System.in);

        // Wyświetlenie informacji początkowych
        System.out.println("MYJNIA SAMOCHODWA");
        System.out.println("Cena mycia: 15 zł");
        System.out.println("Akceptowane monety: 1 zł, 2 zł, 5 zł");

        // Główna pętla programu - działanie automatu
        while (carWashDFA.getCurrentState() < 15) {
            System.out.println("\nWrzuć monetę (1, 2 lub 5 zł):");
            String input = scanner.nextLine().trim();

            // Walidacja wprowadzonych danych - sprawdzenie czy wprowadzono pojedynczą liczbę
            if (!input.matches("^\\d+$")) {
                System.out.println("Błąd: Wprowadź pojedynczą liczbę!");
                continue;
            }

            // Konwersja wprowadzonej wartości na liczbę
            int coin = Integer.parseInt(input);

            // Sprawdzenie czy wprowadzono prawidłowy nominał
            if (coin != 1 && coin != 2 && coin != 5) {
                System.out.println("Błąd: Nieakceptowany nominał monety!");
                continue;
            }

            // Wykonanie przejścia automatu
            carWashDFA.insertCoin(coin);
        }
    }
}
