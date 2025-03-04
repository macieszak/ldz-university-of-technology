import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Random;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

public class FileUpload {
	
	static AtomicInteger activeClients = new AtomicInteger(0);
	final PriorityBlockingQueue<Client> clientQueue = new PriorityBlockingQueue<>();
	List<Client> activeClientsList = new ArrayList<>();
	JTextArea logArea;
	DefaultTableModel tableModel;
	JPanel progressPanel;
	AtomicInteger clientIdCounter = new AtomicInteger(1);
	JLabel[] clientLabels;
	JProgressBar[] progressBars;
	JLabel[] fileLabels;
	JLabel[] priorityLabels;
	
	public FileUpload(JTextArea logArea, DefaultTableModel tableModel, JPanel progressPanel) {
		this.logArea = logArea;
		this.tableModel = tableModel;
		this.progressPanel = progressPanel;
		
		clientLabels = new JLabel[5];
		progressBars = new JProgressBar[5];
		fileLabels = new JLabel[5];
		priorityLabels = new JLabel[5];
		
		progressPanel.setLayout(new GridBagLayout());
		GridBagConstraints gbc = new GridBagConstraints();
		gbc.gridwidth = GridBagConstraints.REMAINDER;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.weightx = 1.0;
		gbc.insets = new Insets(2, 5, 2, 5);
		
		for (int i = 0; i < 5; i++) {
			JPanel threadPanel = new JPanel();
			threadPanel.setLayout(new GridBagLayout());
			threadPanel.setBorder(BorderFactory.createTitledBorder(
					BorderFactory.createLineBorder(Color.GRAY),
					"Thread " + (i + 1)
			));
			
			GridBagConstraints threadGbc = new GridBagConstraints();
			threadGbc.gridwidth = GridBagConstraints.REMAINDER;
			threadGbc.fill = GridBagConstraints.HORIZONTAL;
			threadGbc.weightx = 1.0;
			threadGbc.insets = new Insets(2, 5, 2, 5);
			
			clientLabels[i] = new JLabel("No client in thread");
			progressBars[i] = new JProgressBar();
			progressBars[i].setStringPainted(true);
			fileLabels[i] = new JLabel("No file");
			priorityLabels[i] = new JLabel("Priority: N/A");
			
			threadPanel.add(clientLabels[i], threadGbc);
			threadPanel.add(progressBars[i], threadGbc);
			threadPanel.add(fileLabels[i], threadGbc);
			threadPanel.add(priorityLabels[i], threadGbc);
			
			progressPanel.add(threadPanel, gbc);
		}
	}
	
	public void addClient() {
		int id = clientIdCounter.getAndIncrement();
		Random random = new Random();
		List<File> files = new ArrayList<>();
		int fileCount = random.nextInt(5) + 1;
		
		for (int i = 0; i < fileCount; i++) {
			files.add(new File(random.nextInt(100) + 1));
		}
		
		Client client = new Client(id, files);
		activeClients.incrementAndGet();
		clientQueue.add(client);
		updateTable();
		recalculatePriorities();
	}
	
	private void recalculatePriorities() {
		synchronized (clientQueue) {
			List<Client> clients = new ArrayList<>(clientQueue);
			clientQueue.clear();
			clientQueue.addAll(clients);
		}
	}
	
	public void processUploads() {
		for (int i = 0; i < 5; i++) {
			final int threadIndex = i;
			new Thread(() -> {
				while (true) {
					updateTable();
					File file = null;
					Client client;
					
					synchronized (clientQueue) {
						client = clientQueue.poll();
						
						if (client != null && client.hasFiles()) {
							file = client.getNextFile();
							
							if (client.hasFiles()) {
								clientQueue.add(client);
							} else {
								activeClients.decrementAndGet();
								recalculatePriorities();
							}
						}
					}
					
					if (file != null) {
						String clientText = "Client " + client.id;
						double priority = client.calculatePriority(activeClients.get());
						updateTile(threadIndex, clientText, "File size: " + file.size, 0,
								String.format("Priority: %.2f", priority));
						uploadFile(file, threadIndex, client.id);
					} else {
						updateTile(threadIndex, "Idle", "No file", 0, "Priority: N/A");
						try {
							Thread.sleep(1000);
						} catch (InterruptedException e) {
							Thread.currentThread().interrupt();
						}
					}
				}
			}).start();
		}
	}
	
	private void uploadFile(File file, int threadIndex, int clientId) {
		Random random = new Random();
		int uploadSpeed = (random.nextInt(500) + 300) * file.size;
		
		int steps = 100;
		int delayPerStep = uploadSpeed / steps;
		
		for (int i = 0; i <= steps; i++) {
			try {
				Thread.sleep(delayPerStep);
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			}
			int progress = i;
			SwingUtilities.invokeLater(() -> progressBars[threadIndex].setValue(progress));
		}
		log("Client ID: " + clientId + ", file size:  " + file.size);
	}
	
	private void updateTile(int threadIndex, String clientText, String fileText,
							int progress, String priorityText) {
		SwingUtilities.invokeLater(() -> {
			clientLabels[threadIndex].setText(clientText);
			fileLabels[threadIndex].setText(fileText);
			progressBars[threadIndex].setValue(progress);
			priorityLabels[threadIndex].setText(priorityText);
		});
	}
	
	private void log(String message) {
		SwingUtilities.invokeLater(() -> logArea.append(message + "\n"));
	}
	
	public void updateTable() {
		SwingUtilities.invokeLater(() -> {
			List<Client> allClients = new ArrayList<>(clientQueue);
			allClients.addAll(activeClientsList);
			allClients.removeIf(Objects::isNull);
			allClients.sort(Comparator.comparingInt(client -> client.id));
			
			((DefaultTableModel) tableModel).setRowCount(0);
			for (Client client : allClients) {
				if (client.hasFiles()) {
					double priority = client.calculatePriority(activeClients.get());
					tableModel.addRow(new Object[]{
							client.id,
							client.getFileSizes(),
							client.getFormattedEnqueueTime(),
							String.format("%.2f", priority)
					});
				}
			}
		});
	}
	
}