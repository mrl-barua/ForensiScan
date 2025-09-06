extends Node

# PDFGenerator Service
# Handles generating PDF/HTML reports for quiz results with cross-platform support

signal pdf_generated(file_path: String)
signal pdf_generation_failed(error_message: String)

# PDF content structure
var pdf_content: String = ""
var user_details: Dictionary = {}
var quiz_results: Dictionary = {}

func _ready():
	print("PDFGenerator: Service loaded successfully!")
	print("PDFGenerator: Platform detected: ", OS.get_name())
	print("PDFGenerator: QuizManager available: ", QuizManager != null)
	print("PDFGenerator: LicenseProcessor available: ", LicenseProcessor != null)

func test_pdf_generation():
	"""Test function to check data collection"""
	print("=== PDF GENERATION TEST ===")
	
	# Test data collection directly
	collect_user_details()
	collect_quiz_results()
	
	print("=== TEST USER DETAILS ===")
	print(user_details)
	print("=== TEST QUIZ RESULTS ===")
	print(quiz_results)
	
	# Test simple HTML generation first
	print("=== TESTING SIMPLE HTML GENERATION ===")
	var simple_html = generate_simple_html_test()
	print("Simple HTML length: ", simple_html.length())
	
	print("=== TESTING FULL HTML GENERATION ===")
	var html_content = generate_html_content()
	print("HTML content length: ", html_content.length())
	if html_content.length() < 100:
		print("HTML content (too short): ", html_content)
	
	print("=== TESTING TEXT GENERATION ===") 
	var text_content = generate_text_content()
	print("Text content length: ", text_content.length())
	if text_content.length() < 100:
		print("Text content (too short): ", text_content)
	
	# Try to save the files to see the actual content
	print("=== SAVING TEST FILES ===")
	if OS.get_name() == "Windows":
		var test_html_path = "user://test_report.html"
		var test_text_path = "user://test_report.txt"
		var test_simple_path = "user://test_simple.html"
		
		var html_file = FileAccess.open(test_html_path, FileAccess.WRITE)
		if html_file:
			html_file.store_string(html_content)
			html_file.close()
			print("Test HTML saved to: ", ProjectSettings.globalize_path(test_html_path))
		
		var text_file = FileAccess.open(test_text_path, FileAccess.WRITE)
		if text_file:
			text_file.store_string(text_content)
			text_file.close()
			print("Test text saved to: ", ProjectSettings.globalize_path(test_text_path))
			
		var simple_file = FileAccess.open(test_simple_path, FileAccess.WRITE)
		if simple_file:
			simple_file.store_string(simple_html)
			simple_file.close()
			print("Test simple HTML saved to: ", ProjectSettings.globalize_path(test_simple_path))
	
	print("=== PDF GENERATION TEST COMPLETE ===")

func generate_simple_html_test() -> String:
	"""Generate a simple HTML for testing"""
	var name = user_details.get("name", "Test User")
	var score = quiz_results.get("score", 0)
	var total = quiz_results.get("total_questions", 0)
	var grade = quiz_results.get("grade", "N/A")
	
	var simple_html = "<!DOCTYPE html>\n"
	simple_html += "<html>\n"
	simple_html += "<head><title>Test Report</title></head>\n"
	simple_html += "<body>\n"
	simple_html += "<h1>ForensiScan Test Report</h1>\n"
	simple_html += "<p>Name: " + str(name) + "</p>\n"
	simple_html += "<p>Score: " + str(score) + " out of " + str(total) + "</p>\n"
	simple_html += "<p>Grade: " + str(grade) + "</p>\n"
	simple_html += "</body>\n"
	simple_html += "</html>"
	
	return simple_html

func generate_prelim_results_pdf(output_dir: String = "", custom_filename: String = "") -> String:
	"""Generate PDF for prelim quiz results"""
	print("PDFGenerator: Starting prelim results PDF generation...")
	print("PDFGenerator: Platform: ", OS.get_name())
	
	# Gather all required data
	collect_user_details()
	collect_quiz_results()
	
	# Check if we have valid data
	if quiz_results.is_empty() or quiz_results.get("total_questions", 0) == 0:
		var error = "No valid quiz data found. Please complete a quiz first."
		print("PDFGenerator ERROR: ", error)
		pdf_generation_failed.emit(error)
		return ""
	
	# Generate content based on platform
	var content: String
	var filename: String
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	
	if OS.get_name() == "Android":
		# Generate simple text report for Android
		content = generate_text_content()
		filename = "Prelim_Quiz_Results_%s.txt" % timestamp
	else:
		# Generate HTML content for desktop
		content = generate_html_content()
		filename = "Prelim_Quiz_Results_%s.html" % timestamp
	
	# Debug content generation
	print("PDFGenerator: Content length: ", content.length())
	if content.length() == 0:
		print("PDFGenerator ERROR: Generated content is empty!")
		pdf_generation_failed.emit("Generated content is empty - check data collection")
		return ""
	elif content.length() < 100:
		print("PDFGenerator WARNING: Content seems too short: ", content)
	
	# Use platform-compatible file path
	var file_path = get_platform_compatible_path(filename)
	
	# Create reports directory if it doesn't exist
	ensure_reports_directory()
	
	# Write content to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		var error = "Failed to create report file: " + str(file_path) + " (Error: " + str(FileAccess.get_open_error()) + ")"
		print("PDFGenerator ERROR: ", error)
		pdf_generation_failed.emit(error)
		return ""
	
	file.store_string(content)
	file.close()
	
	print("PDFGenerator: Report generated successfully at: ", file_path)
	
	# Handle platform-specific viewing/sharing
	handle_platform_specific_actions(file_path)
	
	pdf_generated.emit(file_path)
	return file_path

func get_platform_compatible_path(filename: String) -> String:
	"""Get platform-compatible file path"""
	if OS.get_name() == "Android":
		# Use Android external storage or app-specific directory
		return "user://reports/" + filename
	else:
		# Desktop platforms
		return "user://reports/" + filename

func collect_user_details():
	"""Collect user/student details from license system"""
	print("PDFGenerator: Collecting user details...")
	user_details = LicenseProcessor.get_license_details()
	print("PDFGenerator: Raw license details: ", user_details)
	
	# Add system information
	user_details["report_generated"] = Time.get_datetime_string_from_system()
	user_details["app_version"] = "ForensiScan v1.0.0"
	user_details["platform"] = OS.get_name()
	
	print("PDFGenerator: Final user details: ", user_details)

func collect_quiz_results():
	"""Collect quiz results from QuizManager"""
	print("PDFGenerator: Collecting quiz results...")
	print("PDFGenerator: QuizManager score: ", QuizManager.get_score())
	print("PDFGenerator: QuizManager current_set size: ", QuizManager.current_set.size())
	print("PDFGenerator: QuizManager answer history: ", QuizManager.get_answer_history())
	
	# Add safety checks for quiz data
	var score = QuizManager.get_score() if QuizManager.get_score() >= 0 else 0
	var total_questions = QuizManager.current_set.size() if QuizManager.current_set.size() > 0 else 1
	var answers = QuizManager.get_answer_history() if QuizManager.get_answer_history().size() > 0 else []
	
	# Handle case where no quiz was taken
	if total_questions == 1 and answers.size() == 0:
		# Create dummy data to show the problem
		answers = [{"question": "No quiz data available", "selected": "No answer", "correct": "N/A"}]
		total_questions = 1
		score = 0
	
	var percentage = (float(score) / float(total_questions)) * 100.0
	
	quiz_results = {
		"score": score,
		"total_questions": total_questions,
		"percentage": percentage,
		"answers": answers,
		"grade": get_grade_text(percentage),
		"quiz_type": "Preliminary Assessment",
		"completion_time": Time.get_datetime_string_from_system()
	}
	
	print("PDFGenerator: Final quiz results: ", quiz_results)

func get_grade_text(percentage: float) -> String:
	"""Get grade text based on percentage"""
	if percentage >= 90:
		return "Outstanding (A+)"
	elif percentage >= 80:
		return "Excellent (A)"
	elif percentage >= 70:
		return "Good (B)"
	elif percentage >= 60:
		return "Satisfactory (C)"
	else:
		return "Needs Improvement (D)"

func generate_html_content() -> String:
	"""Generate comprehensive HTML content for the PDF report"""
	print("PDFGenerator: Starting HTML generation...")
	print("PDFGenerator: User details: ", user_details)
	print("PDFGenerator: Quiz results: ", quiz_results)
	
	# Check if we have the required data
	if user_details.is_empty():
		print("PDFGenerator ERROR: User details are empty!")
		return ""
	if quiz_results.is_empty():
		print("PDFGenerator ERROR: Quiz results are empty!")
		return ""
	
	# Generate the answers table first
	var answers_table = generate_answers_table_html()
	print("PDFGenerator: Answers table length: ", answers_table.length())
	
	var html = """<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>ForensiScan - Preliminary Quiz Results</title>
	<style>
		body {
			font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
			margin: 0;
			padding: 20px;
			background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
			color: #333;
			line-height: 1.6;
		}
		.container {
			max-width: 800px;
			margin: 0 auto;
			background: white;
			border-radius: 15px;
			box-shadow: 0 20px 40px rgba(0,0,0,0.1);
			overflow: hidden;
		}
		.header {
			background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
			color: white;
			padding: 30px;
			text-align: center;
			position: relative;
		}
		.header::before {
			content: '🔍';
			font-size: 60px;
			display: block;
			margin-bottom: 10px;
		}
		.header h1 {
			margin: 0;
			font-size: 2.5em;
			font-weight: 300;
			letter-spacing: 2px;
		}
		.header h2 {
			margin: 5px 0 0 0;
			font-size: 1.2em;
			opacity: 0.9;
			font-weight: 300;
		}
		.content {
			padding: 40px;
		}
		.section {
			margin-bottom: 40px;
			border-left: 4px solid #667eea;
			padding-left: 20px;
		}
		.section h3 {
			color: #1e3c72;
			font-size: 1.5em;
			margin-bottom: 20px;
			display: flex;
			align-items: center;
			gap: 10px;
		}
		.info-grid {
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: 20px;
			margin-bottom: 30px;
		}
		.info-card {
			background: #f8f9ff;
			padding: 20px;
			border-radius: 10px;
			border: 1px solid #e1e8ff;
		}
		.info-card h4 {
			margin: 0 0 10px 0;
			color: #1e3c72;
			font-size: 1.1em;
		}
		.info-card p {
			margin: 5px 0;
			color: #555;
		}
		.score-highlight {
			background: linear-gradient(135deg, #4CAF50, #45a049);
			color: white;
			padding: 30px;
			border-radius: 15px;
			text-align: center;
			margin: 20px 0;
			box-shadow: 0 10px 20px rgba(76, 175, 80, 0.2);
		}
		.score-highlight h2 {
			margin: 0;
			font-size: 3em;
			font-weight: bold;
		}
		.score-highlight p {
			margin: 10px 0 0 0;
			font-size: 1.2em;
			opacity: 0.9;
		}
		.answers-table {
			width: 100%;
			border-collapse: collapse;
			margin-top: 20px;
			box-shadow: 0 2px 10px rgba(0,0,0,0.1);
			border-radius: 10px;
			overflow: hidden;
		}
		.answers-table th {
			background: #1e3c72;
			color: white;
			padding: 15px;
			text-align: left;
			font-weight: 600;
		}
		.answers-table td {
			padding: 15px;
			border-bottom: 1px solid #e1e8ff;
			vertical-align: top;
		}
		.answers-table tr:last-child td {
			border-bottom: none;
		}
		.answers-table tr:nth-child(even) {
			background: #f8f9ff;
		}
		.correct {
			color: #4CAF50;
			font-weight: bold;
		}
		.incorrect {
			color: #f44336;
			font-weight: bold;
		}
		.question-text {
			font-weight: 600;
			margin-bottom: 10px;
			color: #1e3c72;
		}
		.answer-status {
			display: inline-flex;
			align-items: center;
			gap: 5px;
			padding: 5px 10px;
			border-radius: 20px;
			font-size: 0.9em;
			font-weight: bold;
		}
		.status-correct {
			background: #e8f5e8;
			color: #4CAF50;
		}
		.status-incorrect {
			background: #ffe8e8;
			color: #f44336;
		}
		.footer {
			background: #f8f9ff;
			padding: 20px;
			text-align: center;
			border-top: 1px solid #e1e8ff;
			color: #666;
			font-size: 0.9em;
		}
		.watermark {
			position: fixed;
			bottom: 20px;
			right: 20px;
			opacity: 0.1;
			font-size: 100px;
			color: #1e3c72;
			z-index: -1;
			transform: rotate(-15deg);
		}
		@media print {
			body { background: white; }
			.container { box-shadow: none; }
		}
	</style>
</head>
<body>
	<div class="watermark">🔍</div>
	<div class="container">
		<div class="header">
			<h1>ForensiScan</h1>
			<h2>Digital Forensics Learning Platform</h2>
			<p style="margin-top: 20px; opacity: 0.8;">Preliminary Assessment Results Report</p>
		</div>
		
		<div class="content">
			<div class="section">
				<h3>📊 Assessment Results</h3>
				<div class="score-highlight">
					<h2>%d/%d</h2>
					<p>%s%% - %s</p>
				</div>
			</div>
			
			<div class="section">
				<h3>👤 Student Information</h3>
				<div class="info-grid">
					<div class="info-card">
						<h4>Personal Details</h4>
						<p><strong>Name:</strong> %s</p>
						<p><strong>Semester:</strong> %s</p>
						<p><strong>Device ID:</strong> %s</p>
					</div>
					<div class="info-card">
						<h4>Assessment Details</h4>
						<p><strong>Assessment Type:</strong> %s</p>
						<p><strong>Completion Date:</strong> %s</p>
						<p><strong>Report Generated:</strong> %s</p>
					</div>
				</div>
			</div>
			
			<div class="section">
				<h3>📋 Detailed Answer Review</h3>
				<table class="answers-table">
					<thead>
						<tr>
							<th style="width: 5%;">Q#</th>
							<th style="width: 60%;">Question</th>
							<th style="width: 20%;">Your Answer</th>
							<th style="width: 15%;">Status</th>
						</tr>
					</thead>
					<tbody>
						%s
					</tbody>
				</table>
			</div>
		</div>
		
		<div class="footer">
			<p>Generated by ForensiScan v1.0.0 | Digital Forensics Learning Platform</p>
			<p>Report Date: %s | Platform: %s</p>
			<p style="margin-top: 10px; font-style: italic;">This is an official assessment report. Keep this document for your records.</p>
		</div>
	</div>
</body>
</html>"""
	
	# Prepare format parameters (12 total to match HTML placeholders)
	var format_params = [
		quiz_results.get("score", 0),                                          # 1: %d
		quiz_results.get("total_questions", 0),                                # 2: %d  
		str(quiz_results.get("percentage", 0.0)),                              # 3: %s (percentage as string)
		quiz_results.get("grade", "Not Available"),                            # 4: %s
		user_details.get("name", "Not Available"),                             # 5: %s
		user_details.get("semester", "Not Available"),                         # 6: %s
		user_details.get("device_id", "Not Registered"),                       # 7: %s
		quiz_results.get("quiz_type", "Assessment"),                            # 8: %s
		format_datetime(quiz_results.get("completion_time", "")),              # 9: %s
		format_datetime(user_details.get("report_generated", "")),             # 10: %s
		answers_table,                                                         # 11: %s
		format_datetime(user_details.get("report_generated", "")),             # 12: %s (footer date)
		user_details.get("platform", "Unknown")                               # 13: %s (footer platform)
	]
	
	print("PDFGenerator: Format parameters count: ", format_params.size())
	print("PDFGenerator: Format parameters: ", format_params)
	
	# Count actual format placeholders in HTML (for debugging)
	# Let's use a simpler counting method
	var d_count = 0
	var s_count = 0
	var f_count = 0
	
	# Count %d placeholders
	var pos = 0
	while true:
		pos = html.find("%d", pos)
		if pos == -1:
			break
		d_count += 1
		pos += 2
	
	# Count %s placeholders
	pos = 0
	while true:
		pos = html.find("%s", pos)
		if pos == -1:
			break
		s_count += 1
		pos += 2
	
	# Count %.1f placeholders (none should remain)
	pos = 0
	while true:
		pos = html.find("%.1f", pos)
		if pos == -1:
			break
		f_count += 1
		pos += 4
	
	var total_placeholders = d_count + s_count + f_count
	print("PDFGenerator: HTML template has ", total_placeholders, " format placeholders (%d: ", d_count, ", %s: ", s_count, ", %.1f: ", f_count, ")")
	
	# Format the HTML with GDScript-compatible string replacement
	var formatted_html = ""
	
	# Use manual replacement since GDScript doesn't support % formatting
	print("PDFGenerator: Using manual string replacement (GDScript compatible)...")
	formatted_html = replace_placeholders_manually(html, format_params)
	print("PDFGenerator: Manual replacement length: ", formatted_html.length())
	
	# If still empty, use simple fallback
	if formatted_html.length() == 0:
		print("PDFGenerator: Manual replacement failed, using simple fallback...")
		formatted_html = generate_simple_html_fallback()
		print("PDFGenerator: Fallback HTML length: ", formatted_html.length())
	
	return formatted_html

func replace_placeholders_manually(template: String, params: Array) -> String:
	"""Manually replace placeholders to avoid GDScript % formatting issues"""
	var result = template
	var param_index = 0
	
	# Replace %d placeholders one by one
	while result.find("%d") != -1 and param_index < params.size():
		var pos = result.find("%d")
		if pos != -1:
			result = result.substr(0, pos) + str(params[param_index]) + result.substr(pos + 2)
		param_index += 1
	
	# Replace %s placeholders one by one
	while result.find("%s") != -1 and param_index < params.size():
		var pos = result.find("%s")
		if pos != -1:
			result = result.substr(0, pos) + str(params[param_index]) + result.substr(pos + 2)
		param_index += 1
	
	return result

func generate_simple_html_fallback() -> String:
	"""Generate a simple HTML fallback when complex formatting fails"""
	var score = quiz_results.get("score", 0)
	var total = quiz_results.get("total_questions", 0)
	var percentage = quiz_results.get("percentage", 0.0)
	var grade = quiz_results.get("grade", "Not Available")
	var name = user_details.get("name", "Not Available")
	var semester = user_details.get("semester", "Not Available")
	
	var html = "<!DOCTYPE html>\n"
	html += "<html>\n"
	html += "<head>\n"
	html += "\t<title>ForensiScan Quiz Results</title>\n"
	html += "\t<style>\n"
	html += "\t\tbody { font-family: Arial, sans-serif; margin: 20px; }\n"
	html += "\t\t.header { background: #1e3c72; color: white; padding: 20px; text-align: center; }\n"
	html += "\t\t.content { padding: 20px; }\n"
	html += "\t\t.score { font-size: 24px; font-weight: bold; margin: 20px 0; }\n"
	html += "\t</style>\n"
	html += "</head>\n"
	html += "<body>\n"
	html += "\t<div class=\"header\">\n"
	html += "\t\t<h1>ForensiScan Quiz Results</h1>\n"
	html += "\t</div>\n"
	html += "\t<div class=\"content\">\n"
	html += "\t\t<div class=\"score\">Score: " + str(score) + "/" + str(total) + " (" + str(percentage) + "%)</div>\n"
	html += "\t\t<p><strong>Grade:</strong> " + grade + "</p>\n"
	html += "\t\t<p><strong>Student:</strong> " + name + "</p>\n"
	html += "\t\t<p><strong>Semester:</strong> " + semester + "</p>\n"
	html += "\t\t<p><strong>Generated:</strong> " + format_datetime(user_details.get("report_generated", "")) + "</p>\n"
	html += "\t</div>\n"
	html += "</body>\n"
	html += "</html>"
	
	return html

func repeat_string(s: String, count: int) -> String:
	"""Helper function to repeat a string multiple times"""
	var result = ""
	for i in range(count):
		result += s
	return result

func generate_text_content() -> String:
	"""Generate simple text content for mobile devices"""
	var text = ""
	
	# Header
	text += repeat_string("=", 50) + "\n"
	text += "🔍 FORENSISCAN - PRELIMINARY QUIZ RESULTS\n"
	text += repeat_string("=", 50) + "\n\n"
	
	# Assessment Results
	text += "📊 ASSESSMENT RESULTS\n"
	text += repeat_string("-", 25) + "\n"
	text += "Score: " + str(quiz_results.get("score", 0)) + "/" + str(quiz_results.get("total_questions", 0)) + "\n"
	text += "Percentage: " + str(quiz_results.get("percentage", 0.0)) + "%\n"
	text += "Grade: " + str(quiz_results.get("grade", "Not Available")) + "\n\n"
	
	# Student Information
	text += "👤 STUDENT INFORMATION\n"
	text += repeat_string("-", 25) + "\n"
	text += "Name: %s\n" % user_details.get("name", "Not Available")
	text += "Semester: %s\n" % user_details.get("semester", "Not Available")
	text += "Device ID: %s\n" % user_details.get("device_id", "Not Registered")
	text += "Assessment Type: %s\n" % quiz_results.get("quiz_type", "Assessment")
	text += "Completion Date: %s\n" % format_datetime(quiz_results.get("completion_time", ""))
	text += "Report Generated: %s\n\n" % format_datetime(user_details.get("report_generated", ""))
	
	# Answer Review
	text += "📋 DETAILED ANSWER REVIEW\n"
	text += repeat_string("-", 30) + "\n"
	
	var answers = quiz_results.get("answers", [])
	for i in range(answers.size()):
		var answer = answers[i]
		var question_num = i + 1
		var is_correct = answer.selected == answer.correct
		
		text += "Question " + str(question_num) + ":\n"
		text += str(answer.question) + "\n"
		text += "\n"
		
		if is_correct:
			text += "✅ Your Answer: " + str(answer.selected) + "\n"
			text += "✓ Correct!\n"
		else:
			var selected_answer = answer.selected if answer.selected != "" else "No answer"
			text += "❌ Your Answer: " + str(selected_answer) + "\n"
			text += "✓ Correct Answer: " + str(answer.correct) + "\n"
		
		text += "\n" + repeat_string("-", 30) + "\n"
	
	# Footer
	text += "\nGenerated by ForensiScan v1.0.0\n"
	text += "Digital Forensics Learning Platform\n"
	text += "Report Date: %s\n" % format_datetime(user_details.get("report_generated", ""))
	text += "Platform: %s\n" % user_details.get("platform", "Unknown")
	text += "\nThis is an official assessment report.\n"
	text += "Keep this document for your records.\n"
	
	return text

func generate_answers_table_html() -> String:
	"""Generate HTML table rows for answers"""
	var table_html = ""
	var answers = quiz_results.get("answers", [])
	
	for i in range(answers.size()):
		var answer = answers[i]
		var question_num = i + 1
		var is_correct = answer.selected == answer.correct
		
		var status_class = "status-correct" if is_correct else "status-incorrect"
		var status_icon = "✅" if is_correct else "❌"
		var status_text = "Correct" if is_correct else "Incorrect"
		
		var your_answer = answer.selected if answer.selected != "" else "No Answer"
		var correct_answer_display = "" if is_correct else "<br><strong>Correct Answer:</strong> " + str(answer.correct)
		
		table_html += "\n\t\t<tr>\n"
		table_html += "\t\t\t<td><strong>" + str(question_num) + "</strong></td>\n"
		table_html += "\t\t\t<td>\n"
		table_html += "\t\t\t\t<div class=\"question-text\">" + str(answer.question) + "</div>\n"
		table_html += "\t\t\t\t" + correct_answer_display + "\n"
		table_html += "\t\t\t</td>\n"
		table_html += "\t\t\t<td>" + str(your_answer) + "</td>\n"
		table_html += "\t\t\t<td>\n"
		table_html += "\t\t\t\t<div class=\"answer-status " + status_class + "\">\n"
		table_html += "\t\t\t\t\t" + status_icon + " " + status_text + "\n"
		table_html += "\t\t\t\t</div>\n"
		table_html += "\t\t\t</td>\n"
		table_html += "\t\t</tr>\n\t\t"
	
	return table_html

func format_datetime(datetime_string: String) -> String:
	"""Format datetime string for display"""
	if datetime_string == "":
		return "Not Available"
	
	# Convert from ISO format to readable format
	var parts = datetime_string.split("T")
	if parts.size() < 2:
		return datetime_string
	
	var date_part = parts[0]
	var time_part = parts[1].split(".")[0]  # Remove milliseconds
	
	return date_part + " at " + time_part

func ensure_reports_directory():
	"""Ensure reports directory exists"""
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("reports"):
		dir.make_dir("reports")
		print("PDFGenerator: Created reports directory")

func handle_platform_specific_actions(file_path: String):
	"""Handle platform-specific actions for viewing/sharing reports"""
	if OS.get_name() == "Android":
		print("PDFGenerator: Android detected - Report saved to app directory")
		print("PDFGenerator: File location: ", OS.get_user_data_dir() + "/reports/")
		# On Android, we could implement sharing via Intent if needed
		# For now, the file is saved and accessible
	else:
		print("PDFGenerator: Desktop platform - Report available for viewing")

func convert_to_pdf_if_possible(html_file_path: String) -> String:
	"""Attempt to convert HTML to PDF if tools are available"""
	# For now, we'll return the HTML file path
	# In a production environment, you could:
	# 1. Use wkhtmltopdf via OS.execute() (desktop only)
	# 2. Use a web API for PDF conversion
	# 3. Integrate a PDF library
	
	print("PDFGenerator: HTML report available at: ", html_file_path)
	
	if OS.get_name() != "Android":
		print("PDFGenerator: To convert to PDF, open the HTML file in a browser and print to PDF")
	else:
		print("PDFGenerator: On Android, the report is saved in HTML format")
	
	return html_file_path

func open_report_location():
	"""Open the reports directory in file explorer"""
	var reports_path = OS.get_user_data_dir() + "/reports"
	print("PDFGenerator: Reports saved to: ", reports_path)
	
	if OS.get_name() == "Android":
		print("PDFGenerator: Android - Reports are saved in app data directory")
		print("PDFGenerator: Use a file manager app to navigate to: ", reports_path)
		# On Android, we could implement an Intent to open file manager
		# OS.request_permissions() might be needed for external storage
	else:
		# Try to open the directory in file explorer for desktop platforms
		if OS.get_name() == "Windows":
			OS.execute("explorer.exe", [reports_path.replace("/", "\\")])
		elif OS.get_name() == "macOS":
			OS.execute("open", [reports_path])
		elif OS.get_name() == "Linux":
			OS.execute("xdg-open", [reports_path])
