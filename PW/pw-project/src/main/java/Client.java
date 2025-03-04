import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

public class Client implements Comparable<Client> {
	int id;
	Queue<File> files;
	long enqueueTime;	//czas dodania do systemu
	private int smallestFileSize;  // Przechowuje rozmiar najmniejszego pliku
	
	public Client(int id, List<File> files) {
		this.id = id;
		files.sort(Comparator.comparingInt(f -> f.size));
		this.files = new LinkedList<>(files);
		this.enqueueTime = System.currentTimeMillis();
		this.smallestFileSize = files.isEmpty() ? 0 : files.get(0).size;
	}
	
	public File getNextFile() {
		File file = files.poll();
		updateSmallestFileSize();
		return file;
	}
	
	private void updateSmallestFileSize() {
		if (!files.isEmpty()) {
			this.smallestFileSize = files.peek().size;
		}
	}
	
	public boolean hasFiles() {
		return !files.isEmpty();
	}
	
	public String getFileSizes() {
		StringBuilder sb = new StringBuilder();
		for (File file : files) {
			sb.append(file.size).append(", ");
		}
		return !sb.isEmpty() ? sb.substring(0, sb.length() - 2) : "";
	}
	
//	public double calculatePriority(int activeClientsCount) {
//		// y = x^(1/3) * k
//		return Math.pow(smallestFileSize, 1.0/3.0) * activeClientsCount;
//	}
	
	public double calculatePriority(int activeClientsCount) {
		double firstFunction = Math.pow(smallestFileSize, 1.0/3.0) * activeClientsCount;
		double secondFunction = Math.pow(smallestFileSize, 3) / Math.pow(activeClientsCount, 2);
		
		return firstFunction + secondFunction;
	}
	
	public String getFormattedEnqueueTime() {
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
		return sdf.format(new Date(enqueueTime));
	}
	
	@Override
	public int compareTo(Client other) {
		int activeClientsCount = FileUpload.activeClients.get();
		double priorityThis = calculatePriority(activeClientsCount);
		double priorityOther = other.calculatePriority(activeClientsCount);
		
		// Mniejszy czas oczekiwania (y) oznacza wyższy priorytet
		return Double.compare(priorityThis, priorityOther);
	}
	
}


//return Math.pow(smallestFileSize, 1.0/3.0) * activeClientsCount;
//return Math.pow(smallestFileSize, 3) / Math.pow(activeClientsCount, 2);