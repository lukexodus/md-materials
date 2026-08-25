## Managing Users


In Linux, managing users involves creating, editing, and deleting them. These tasks can be performed using commands like `useradd`, `usermod`, and `userdel`.

---

**1. Create a User**

To create a new user, use the `useradd` command:

**Basic Syntax**:

```bash
sudo useradd <username>
```

This will create a new user with the specified username, but it may not create a home directory or set a password unless explicitly specified.

**Steps to Create a User Properly**:

1. **Create the User and Home Directory**:
    
    ```bash
    sudo useradd -m <username>
    ```
    
    - **`-m`**: Ensures that a home directory (e.g., `/home/username`) is created for the user.
2. **Set a Password for the User**: After creating the user, set their password:
    
    ```bash
    sudo passwd <username>
    ```
    
    Enter the desired password when prompted.
    
3. **Optional: Add the User to a Group**: Add the user to a specific group (e.g., `sudo` for administrative privileges):
    
    ```bash
    sudo usermod -aG <group> <username>
    ```
    
    Example:
    
    ```bash
    sudo usermod -aG sudo john
    ```
    
    - **`-aG`**: Adds the user to the specified group without removing them from other groups.

---

**2. Edit a User**

To modify an existing user, use the `usermod` command:

**Common Modifications**:

1. **Change the User's Username**:
    
    ```bash
    sudo usermod -l <new_username> <current_username>
    ```
    
    - This changes the login name of the user.
2. **Change the User's Home Directory**:
    
    ```bash
    sudo usermod -d /new/home/directory -m <username>
    ```
    
    - **`-d`**: Specifies the new home directory.
    - **`-m`**: Moves the contents of the old home directory to the new one.
3. **Lock a User Account**: Temporarily disable a user's login:
    
    ```bash
    sudo usermod -L <username>
    ```
    
    - **`-L`**: Locks the account.
4. **Unlock a User Account**:
    
    ```bash
    sudo usermod -U <username>
    ```
    
    - **`-U`**: Unlocks the account.
5. **Add the User to a Group**: Add a user to a specific group:
    
    ```bash
    sudo usermod -aG <group> <username>
    ```
    
    Example:
    
    ```bash
    sudo usermod -aG docker john
    ```
    

---

**3. Delete a User**

To remove a user, use the `userdel` command:

**Basic Syntax**:

```bash
sudo userdel <username>
```

This removes the user but **does not delete their home directory** or files.

**Remove User and Their Home Directory**:

If you also want to delete the user's home directory and mail spool:

```bash
sudo userdel -r <username>
```

- **`-r`**: Deletes the user's home directory and files in `/var/spool/mail/`.

**Force Remove a Logged-In User**:

If the user is currently logged in, you may need to force the removal:

```bash
sudo userdel -f <username>
```

---

**4. Examples**

1. **Create a User with a Home Directory and Password**:
    
    ```bash
    sudo useradd -m john
    sudo passwd john
    ```
    
2. **Add a User to the `sudo` Group**:
    
    ```bash
    sudo usermod -aG sudo john
    ```
    
3. **Delete a User and Their Home Directory**:
    
    ```bash
    sudo userdel -r john
    ```
    

---

**5. Check Existing Users**

To see all users on the system, check the `/etc/passwd` file:

```bash
cat /etc/passwd
```

Each line corresponds to a user, with the first field being the username.

---

**Best Practices**

- Avoid using the root account for daily tasks; instead, create a non-root user with administrative privileges (`sudo` group).
- Use strong passwords for all user accounts.
- Lock unused or inactive accounts to enhance security:
    
    ```bash
    sudo usermod -L <username>
    ```
    
---

