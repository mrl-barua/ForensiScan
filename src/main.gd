extends Node

func _ready():
	print("ForensiScan App started!")
	
	# Wait a moment then test PDF generation
	await get_tree().create_timer(2.0).timeout
	test_pdf_system()

func test_pdf_system():
	print("=== TESTING PDF SYSTEM ===")
	
	# Check if autoloads are available
	print("QuizManager available: ", QuizManager != null)
	print("LicenseProcessor available: ", LicenseProcessor != null) 
	print("PDFGenerator available: ", PDFGenerator != null)
	
	# Create test data
	if QuizManager:
		QuizManager.create_test_data()
	
	if LicenseProcessor:
		LicenseProcessor.create_test_license_data()
	
	if PDFGenerator:
		# Test the PDF generation system
		PDFGenerator.test_pdf_generation()
		
		# Try to generate actual PDF
		print("=== TESTING ACTUAL PDF GENERATION ===")
		var result = PDFGenerator.generate_prelim_results_pdf()
		print("PDF Generation result: ", result)
	else:
		print("PDFGenerator not available!")