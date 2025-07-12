  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.account_circle, color: Colors.blue[600]),
          const SizedBox(width: 8),
          const Text('Account Settings'),
        ],
      ),
      content: Container(
        width: 400,
        height: 500, // Fixed height to prevent overflow
        child: SingleChildScrollView( // Make it scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Information Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Username
                    Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Username: ', style: TextStyle(fontWeight: FontWeight.w500)),
                        Expanded(
                          child: Text(
                            widget.userId,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Password (Always hidden with dots)
                    Row(
                      children: [
                        const Icon(Icons.lock, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Password: ', style: TextStyle(fontWeight: FontWeight.w500)),
                        Expanded(
                          child: Text(
                            '••••••••••••',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Support Information
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, size: 16, color: Colors.orange),
                              const SizedBox(width: 6),
                              const Text(
                                'Password Reset',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Contact support: juntao540@gmail.com',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Text(
                            'Password reset is not automated yet.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Account Created Date
                    if (widget.userProfile?['created_at'] != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Created: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Expanded(
                            child: Text(
                              widget.userProfile!['created_at'].toString().split(' ')[0],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    
                    // Last Login
                    if (widget.userProfile?['last_login'] != null)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Last Login: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          Expanded(
                            child: Text(
                              widget.userProfile!['last_login'].toString().split(' ')[0],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Account Actions
              Text(
                'Account Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                subtitle: const Text('Update your account password'),
                onTap: () {
                  Navigator.pop(context);
                  _showChangePasswordDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Change Username'),
                subtitle: const Text('Update your username'),
                onTap: () {
                  Navigator.pop(context);
                  _showChangeUsernameDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Switch Account'),
                subtitle: const Text('Log out and sign in with different account'),
                onTap: () {
                  Navigator.pop(context);
                  _showSwitchAccountDialog(context, widget.onLogout);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Permanently delete this account and all data'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
