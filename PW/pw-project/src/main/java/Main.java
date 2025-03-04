import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;

public class Main {
	public static void main(String[] args) {
		
		try {
			UIManager.setLookAndFeel(UIManager.getCrossPlatformLookAndFeelClassName());
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		JFrame frame = new JFrame("Concurrent Programming Project");
		frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		frame.setSize(1200, 800);
		
		JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
		splitPane.setResizeWeight(0.5);
		splitPane.setBorder(null);
		
		JPanel leftPanel = new JPanel(new BorderLayout(5, 5));
		leftPanel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
		
		DefaultTableModel tableModel = new DefaultTableModel(
				new String[]{"Client ID", "File Sizes", "Enqueue Time", "Priority"}, 0);
		JTable table = new JTable(tableModel);
		table.setBackground(new Color(196, 220, 243, 255)); // Jasnoszare tło tabeli
		table.setGridColor(new Color(200, 200, 200)); // Kolor linii siatki
		table.setFont(new Font("Arial", Font.BOLD, 12));
		table.setFillsViewportHeight(true);
		
		table.getColumnModel().getColumn(0).setPreferredWidth(80);
		table.getColumnModel().getColumn(1).setPreferredWidth(250);
		table.getColumnModel().getColumn(2).setPreferredWidth(150);
		table.getColumnModel().getColumn(3).setPreferredWidth(100);
		
		JScrollPane tableScrollPane = new JScrollPane(table);
		leftPanel.add(tableScrollPane, BorderLayout.CENTER);
		
		JPanel controlPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
		JButton addButton = new JButton("Add Client");
		addButton.setBackground(new Color(40, 167, 69));
		addButton.setForeground(Color.WHITE);
		addButton.setFont(new Font("Arial", Font.BOLD, 14));
		JButton startButton = new JButton("Start Simulation");
		startButton.setBackground(new Color(23, 162, 184));
		startButton.setForeground(Color.WHITE);
		startButton.setFont(new Font("Arial", Font.BOLD, 14));
		controlPanel.add(addButton);
		controlPanel.add(startButton);
		leftPanel.add(controlPanel, BorderLayout.SOUTH);
		
		JPanel rightPanel = new JPanel(new BorderLayout(5, 5));
		rightPanel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
		
		JPanel progressPanel = new JPanel();
		progressPanel.setLayout(new BoxLayout(progressPanel, BoxLayout.Y_AXIS)); // Ustawienie wątków w pionie
		JScrollPane progressScrollPane = new JScrollPane(progressPanel);
		progressScrollPane.setBorder(null);
		progressScrollPane.getVerticalScrollBar().setUnitIncrement(16);
		
		JTextArea logArea = new JTextArea(12, 40);
		logArea.setEditable(false);
		JScrollPane logScrollPane = new JScrollPane(logArea);
		logScrollPane.setBorder(BorderFactory.createTitledBorder("INFO"));
		
		rightPanel.add(progressScrollPane, BorderLayout.NORTH);
		rightPanel.add(logScrollPane, BorderLayout.SOUTH);
		
		splitPane.setLeftComponent(leftPanel);
		splitPane.setRightComponent(rightPanel);
		
		FileUpload system = new FileUpload(logArea, tableModel, progressPanel);
		
		addButton.addActionListener(e -> system.addClient());
		startButton.addActionListener(e -> {
			SwingUtilities.invokeLater(system::updateTable);
			system.processUploads();
			startButton.setEnabled(false);
		});
		
		frame.add(splitPane);
		frame.setLocationRelativeTo(null);
		frame.setVisible(true);
		
		for (int i = 0; i < 10; i++) {
			system.addClient();
		}
		
	}
	
}