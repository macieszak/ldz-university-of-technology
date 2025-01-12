import java.util.ArrayList;
import java.util.List;

/**
 * Program symulujący automat do pobierania opłat w myjni samochodowej
 * wykorzystujący model deterministycznego automatu skończonego (DFA).
 *
 * @author Maciej Maksymiuk
 */
public class CarWashDFA {

    // stan początkowy automatu = 0
    private static final int INITIAL_STATE = 0;

    // stan końcowy automatu = 15, oznacza, że zebraliśmy potrzebną kwotę do skorzystania z myjni
    private static final int END_STATE = 15;

    /**
     * Tablica przejść automatu reprezentująca funkcję przejścia δ(q,a), gdzie:
     * q - stan automatu (indeks wiersza)
     * a - symbol wejściowy (nominał monety - indeks kolumny)
     *
     * Format tablicy:
     * [stan][0] - aktualny stan
     * [stan][1] - stan po wrzuceniu monety 1 zł
     * [stan][2] - stan po wrzuceniu monety 2 zł
     * [stan][3] - stan po wrzuceniu monety 5 zł
     *
     * Przykład:
     * TRANSITION_TABLE[0] = {0, 1, 2, 5} oznacza:
     * - aktualny stan to q0
     * - po wrzuceniu 1 zł przechodzimy do stanu q1
     * - po wrzuceniu 2 zł przechodzimy do stanu q2
     * - po wrzuceniu 5 zł przechodzimy do stanu q5
     */
    private static final int[][] TRANSITION_TABLE = new int[20][4];

    // Stan nieprawidłowy, używany dla stanów końcowych gdzie nie ma przejść
    private static final int INVALID_STATE = -1;

    // Lista przechowująca historię stanów automatu
    private final List<Integer> stateHistory = new ArrayList<>();

    // Lista do przechowywania historii wrzuconych monet
    private final List<Integer> coinHistory = new ArrayList<>();

    // Aktualny stan automatu
    private int currentState = INITIAL_STATE;

    // Suma wrzuconych pieniędzy
    private int totalAmount = 0;

    /**
     * Konstruktor inicjalizujący automat.
     * Ustawia stan początkowy i inicjalizuje tablicę przejść.
     */
    public CarWashDFA() {
        initializeTransitionTable();
        stateHistory.add(0);
    }

    /**
     * Inicjalizacja tablicy przejść automatu.
     * Definiuje wszystkie możliwe przejścia między stanami dla każdego nominału.
     * Implementacja funkcji przejścia δ(q,a) = q'
     * gdzie:
     * q - stan bieżący
     * a - symbol wejściowy (nominał)
     * q' - stan następny
     */
    private void initializeTransitionTable() {
        // Definicja przejść dla stanów q0-q14
        // Format: {stan_aktualny, przejście_1zł, przejście_2zł, przejście_5zł}
        TRANSITION_TABLE[0] = new int[]{0, 1, 2, 5};   // Przejścia ze stanu q0
        TRANSITION_TABLE[1] = new int[]{1, 2, 3, 6};   // Przejścia ze stanu q1
        TRANSITION_TABLE[2] = new int[]{2, 3, 4, 7};   // Przejścia ze stanu q2
        TRANSITION_TABLE[3] = new int[]{3, 4, 5, 8};   // Przejścia ze stanu q3
        TRANSITION_TABLE[4] = new int[]{4, 5, 6, 9};   // Przejścia ze stanu q4
        TRANSITION_TABLE[5] = new int[]{5, 6, 7, 10};  // Przejścia ze stanu q5
        TRANSITION_TABLE[6] = new int[]{6, 7, 8, 11};  // Przejścia ze stanu q6
        TRANSITION_TABLE[7] = new int[]{7, 8, 9, 12};  // Przejścia ze stanu q7
        TRANSITION_TABLE[8] = new int[]{8, 9, 10, 13}; // Przejścia ze stanu q8
        TRANSITION_TABLE[9] = new int[]{9, 10, 11, 14};// Przejścia ze stanu q9
        TRANSITION_TABLE[10] = new int[]{10, 11, 12, 15}; // Przejścia ze stanu q10
        TRANSITION_TABLE[11] = new int[]{11, 12, 13, 16}; // Przejścia ze stanu q11
        TRANSITION_TABLE[12] = new int[]{12, 13, 14, 17}; // Przejścia ze stanu q12
        TRANSITION_TABLE[13] = new int[]{13, 14, 15, 18}; // Przejścia ze stanu q13
        TRANSITION_TABLE[14] = new int[]{14, 15, 16, 19}; // Przejścia ze stanu q14

        // Inicjalizacja stanów końcowych (q15-q19)
        // Stany końcowe nie mają przejść do innych stanów
        for (int i = 15; i < 20; i++) {
            TRANSITION_TABLE[i] = new int[]{i, INVALID_STATE, INVALID_STATE, INVALID_STATE};
        }
    }

    //metoda pomocniczna, wyświetlająca na konsoli tabele przejść
    public void displayTransitionTable() {

        System.out.println("TABLICA PRZEJŚĆ");

        int columnWidth = 8;

        // Nagłówek tabeli
        String header = String.format("%-" + columnWidth + "s", "δ");
        header += String.format("%-" + columnWidth + "s", "1");
        header += String.format("%-" + columnWidth + "s", "2");
        header += String.format("%-" + columnWidth + "s", "5");

        // Linia pozioma pod nagłówkiem
        String horizontalLine = "-".repeat(columnWidth * 4);

        System.out.println(header);
        System.out.println(horizontalLine);

        // Wyświetlanie zawartości tabeli
        for (int i = 0; i < TRANSITION_TABLE.length; i++) {
            // Stan początkowy
            String row = String.format("%-" + columnWidth + "s", "q" + i);

            // Stany przejść
            if (i < 15) {
                // Dla stanów q0-q14 wyświetlamy przejścia
                for (int j = 1; j < 4; j++) {
                    row += String.format("%-" + columnWidth + "s", "q" + TRANSITION_TABLE[i][j]);
                }
            } else {
                // Dla stanów q15-q19 wyświetlamy "--"
                for (int j = 1; j < 4; j++) {
                    row += String.format("%-" + columnWidth + "s", "--");
                }
            }

            System.out.println(row);
        }
    }

    /**
     * Obsługuje proces wrzucenia monety do automatu.
     * Aktualizuje stan automatu, zapisuje historię i wyświetla aktualny status.
     *
     * @param coin Nominał wrzuconej monety (1, 2 lub 5 zł)
     */
    public void insertCoin(int coin) {
        // Dodaje wartość monety do całkowitej sumy
        totalAmount += coin;

        // Dodaje monetę do historii wrzuconych monet
        coinHistory.add(coin);

        // Pobiera indeks odpowiadający nominałowi monety w tablicy przejść
        int coinIndex = getCoinIndex(coin);

        // Wyznacza nowy stan automatu na podstawie tablicy przejść
        // TRANSITION_TABLE[obecny_stan][indeks_monety] = nowy_stan
        currentState = TRANSITION_TABLE[currentState][coinIndex];

        // Zapisuje nowy stan do historii stanów automatu
        stateHistory.add(currentState);

        // Wyświetla informacje o aktualnej transakcji
        System.out.println("Wrzucono: " + coin + " zł.");
        System.out.println("Kredyt: " + totalAmount + " zł.");
        System.out.println("Aktualny stan automatu : q" + currentState);

        // Sprawdza czy osiągnięto lub przekroczono wymaganą kwotę (15 zł)
        // Stany >= 15 są stanami końcowymi
        if (currentState >= 15) {
            printTicket(); // Drukuje bilet jeśli zebrano wymaganą kwotę
        }
    }

    /**
     * Drukuje bilet na podstawie wrzuconej kwoty.
     * Jeśli użytkownik wrzucił więcej niż 15 zł, informuje o wydawanej reszcie.
     * Wyświetla historię przejść między stanami automatu oraz stan końcowy.
     */
    private void printTicket() {
        // Wyświetlenie informacji o bilecie
        System.out.println("\n=== BILET NA MYCIE ===");
        System.out.println("Wartość: 15 zł");

        // Sprawdzenie, czy należy wydać resztę
        if (totalAmount > 15) {
            System.out.println("Reszta do wydania: " + (totalAmount - 15) + " zł");
        }
        System.out.println("==================\n");

        // Wyświetlenie historii wpłat
        System.out.println("Historia wpłat: ");
        for (int i = 0; i < coinHistory.size(); i++) {
            System.out.print("---" + coinHistory.get(i));
        }
        System.out.println();

        // Wyświetlenie historii przejść między stanami
        System.out.println("Historia stanów automatu:");
        for (int i = 0; i < stateHistory.size(); i++) {
            System.out.print("---q" + stateHistory.get(i));
        }

        // Wyświetlenie stanu końcowego
        System.out.println("\nStan końcowy: q" + currentState);
    }

    /**
     * Zwraca indeks tablicy przejść odpowiadający wrzuconej monecie.
     *
     * @param coin Wartość wrzuconej monety (1, 2, 5 zł).
     * @return Indeks tablicy przejść (0 dla 1 zł, 1 dla 2 zł, 2 dla 5 zł).
     * @throws IllegalStateException Jeśli wrzucona moneta jest nieprawidłowa.
     */
    private int getCoinIndex(int coin) {
        return switch (coin) {
            case 1 -> 1;
            case 2 -> 2;
            case 5 -> 3;
            default -> throw new IllegalStateException("Nieprawidłowy nominał monety" + coin);
        };
    }

    /**
     * Zwraca bieżący stan automatu.
     *
     * @return Bieżący stan automatu jako liczba całkowita.
     */
    public int getCurrentState() {
        return currentState;
    }

}
