# **NordTheme Documentation**

## **Overview**

The **NordTheme** repository provides a theme for **SDDM (Simple Desktop Display Manager)**, utilizing the **Nord color palette**. It enhances the login screen with a sleek, modern design and colors inspired by the Nord theme.

### **Features**
- Implements the **Nord color scheme** for the login screen.
- Customizable using QML.
- Minimalistic, clean design suitable for various Linux environments.

---

## **Installation**

To use the **NordTheme** for your SDDM login manager, follow these steps:

1. **Clone the repository**:

   Open a terminal and run the following command:
   ```bash
   git clone https://github.com/aleatd/NordTheme.git
   ```

2. **Install the theme**:

   - Copy the theme to the SDDM themes directory (default path: `/usr/share/sddm/themes/`):
     ```bash
     sudo cp -r NordTheme /usr/share/sddm/themes/
     ```

3. **Configure SDDM to use the theme**:

   - Open the SDDM configuration file (`/etc/sddm.conf`) in your text editor:
     ```bash
     sudo nano /etc/sddm.conf
     ```

   - Add or modify the following line under the `[Theme]` section:
     ```ini
     Current=NordTheme
     ```

4. **Restart SDDM**:

   Restart SDDM for the changes to take effect:
   ```bash
   sudo systemctl restart sddm
   ```

---

## **Files Structure**

Here is an overview of the project files and directories:

- **`Main.qml`**: The main QML file that defines the overall structure and layout of the login screen.
- **`theme.conf`**: Configuration file that contains settings for the theme, including the theme name, description, and version.
- **`assets/`**: Directory containing images, icons, and other visual assets used by the theme.
- **`components/`**: Folder containing reusable QML components for easier customization.
- **`wallpaper/`**: Directory with the wallpaper image for the login screen.

---

## **Customization**

You can customize the theme by editing the following files:

- **Main.qml**: Modify the layout, colors, and other UI elements of the login screen.
- **theme.conf**: Adjust the theme name and description.
- **wallpaper**: Change the wallpaper to match your system’s aesthetic.

The **NordTheme** is built using QML, allowing extensive customization of the UI elements. You can change the layout, colors, and overall appearance by modifying these files to fit your needs.

---

## **Contributing**

To contribute to the **NordTheme**, you can:

1. Fork the repository.
2. Make your changes or improvements.
3. Create a pull request to submit your changes.

---

## **License**

This theme is open-source and licensed under the **GNU GPL License**. See the LICENSE file for more details.
