# **PowerShell Folder Backup Script**

A simple yet powerful PowerShell script to create timestamped ZIP backups of specified folders. Ideal for quick personal backups or archiving project states.

## **Table of Contents**

* [Features](#bookmark=id.z6lg2dj9c6ro)  
* [Prerequisites](#bookmark=id.tt1m0ao47mg3)  
* [How to Use](#bookmark=id.ec0bhf8ep2jc)  
* [Examples](#bookmark=id.n2w9ekeaohyv)  
* [Filename Format](#bookmark=id.k0z4zr795roi)  
* [Notes](#bookmark=id.yq4grjh8ew7h)  
* [License](#bookmark=id.t79skj698295)

## **Background**

This is a part of the need to Backup Chrome Profiles 
* Blog post at: https://jorgep.com/blog/how-to-back-up-all-chrome-profiles-from-your-computer/
* GitHub at: https://github.com/jorper98/ChromeCleaner

## **Features**

* **Timestamped Backups:** Automatically includes the current date and time in the backup filename for easy chronological sorting.  
* **Custom Filename:** The output ZIP file is named using the format YYYYMMDDHHMMSS-BKP-\[FolderName\].zip, where \[FolderName\] is the sanitized name of the source folder (only alphanumeric characters and underscores).  
* **Error Handling:** Checks if the source folder exists and provides clear error messages if issues arise.  
* **Size Calculation (Optional):** Estimates and displays the total size of the source folder before compression begins.  
* **PowerShell Native:** Utilizes built-in PowerShell cmdlets (Compress-Archive), requiring no external dependencies beyond PowerShell itself.

## **Prerequisites**

* **PowerShell 5.0 or newer:** The Compress-Archive cmdlet, used for ZIP creation, requires PowerShell 5.0 or later.  
  * Windows 10, Windows Server 2016, and newer versions typically have this by default.  
  * You can check your PowerShell version by running $PSVersionTable.PSVersion in a PowerShell console.

## **How to Use**

1. **Save the Script:** Save the script content (e.g., as backup\_folder.ps1) to a location on your computer.  
2. **Open PowerShell:** Open a PowerShell console.  
3. **Navigate (Optional):** (Optional but recommended) Navigate to the directory where you saved the script using cd C:\\path\\to\\your\\script.  
4. **Run the Script:** Execute the script, providing the full path to the folder you wish to backup as the first argument.  
   .\\backup\_folder.ps1 "C:\\Path\\To\\Your\\Source Folder"

   * If you don't provide a SourceFolder argument, PowerShell will automatically prompt you to enter it.  
   * The generated ZIP file will be saved in the same directory from which you run the script.

## **Examples**

### **Example 1: Backing up a standard project folder**

.\\backup\_folder.ps1 "C:\\Users\\YourUser\\Documents\\My Project"

* **Description:** This command will create a ZIP archive of the "My Project" folder.  
* **Generated Filename Example:** 20250623143000-BKP-My\_Project.zip

### **Example 2: Backing up a system folder with special characters (sanitized)**

.\\backup\_folder.ps1 "$env:USERPROFILE\\AppData\\Local\\Google\\Chrome\\User Data"

* **Description:** This command backs up the Google Chrome User Data folder. The folder name "User Data" will be sanitized in the backup filename.  
* **Generated Filename Example:** 20250623143000-BKP-User\_Data.zip

## **Filename Format**

The backup file will follow this naming convention: YYYYMMDDHHMMSS-BKP-\[FolderName\].zip

* YYYYMMDDHHMMSS: The timestamp (YearMonthDayHourMinuteSecond) when the backup was created.  
* BKP: A static string indicating "Backup".  
* \[FolderName\]: The last segment of the SourceFolder path, with any non-alphanumeric or non-underscore characters replaced by underscores, and multiple consecutive underscores collapsed into one.

## **Notes**

* The script uses Compress-Archive which might not provide a real-time progress bar, especially for very large folders. A "Please wait" message is displayed.  
* The \-Force parameter is used with Compress-Archive, meaning if a backup file with the exact same name already exists in the destination, it will be overwritten.  
* The \-CompressionLevel Fastest is chosen for quicker backup times. You can change this to Optimal for smaller file sizes (at the cost of slower compression) or NoCompression for fastest archiving without compression.

## **License**

This project is open-source and available under the [MIT License](https://opensource.org/licenses/MIT).

## **Contact**

Please feel free to contact me if you have ideas or issues with this script either here or via X: @jorper98
