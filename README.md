# QA Pilot — Demo App

A single-page app packed with interactive elements for testing the Narrative QA bot end-to-end.

## Interactive Elements

| Element | `data-testid` | Description |
|---------|--------------|-------------|
| Email input | `login-email` | Login form email |
| Password input | `login-password` | Login form password |
| Login button | `login-submit` | Submits login (valid: test@example.com / password123) |
| Login status | `login-status` | Success/error message after login |
| Counter value | `counter-value` | Shows current count |
| Increment | `counter-increment` | +1 |
| Decrement | `counter-decrement` | -1 |
| Reset | `counter-reset` | Back to 0 |
| Todo input | `todo-input` | New todo text field |
| Add todo | `todo-add-btn` | Adds item to list |
| Todo list | `todo-list` | Container for all items |
| Todo count | `todo-count` | "N items remaining" |
| Checkboxes | `check-unit`, `check-integration`, `check-e2e`, `check-performance` | Test type selection |
| Checkbox result | `checkbox-result` | Shows selected options |
| Contact name | `contact-name` | Full name field |
| Contact subject | `contact-subject` | Dropdown select |
| Contact message | `contact-message` | Textarea |
| Contact submit | `contact-submit` | Sends form |
| Contact alert | `contact-alert` | Success/error alert |
| Toggles | `toggle-email`, `toggle-dark`, `toggle-autorun` | Settings switches |
| Toggle status | `toggle-status` | Reflects toggle state |
| Quantity input | `quantity-input` | Number input (1–10) |
| Order button | `order-btn` | Disabled if qty out of range |
| Order alert | `order-alert` | Order confirmation |
| Tab buttons | `tab-overview`, `tab-details`, `tab-history` | Tab switcher |
| Tab panels | `panel-overview`, `panel-details`, `panel-history` | Tab content |
| Open modal | `open-modal-btn` | Opens confirmation modal |
| Disabled button | `disabled-btn` | Always disabled |
| Clear all | `clear-all-btn` | Resets all state |
| Modal overlay | `modal-overlay` | Click outside to close |
| Modal confirm | `modal-confirm` | Confirms modal action |
| Modal cancel | `modal-cancel` | Dismisses modal |

## Deploy to your domain

### Option A — Nginx on EC2 (recommended)

```bash
# On your EC2 instance
sudo mkdir -p /var/www/test-app
sudo cp index.html /var/www/test-app/

# Nginx config at /etc/nginx/sites-available/test-app
server {
    listen 80;
    server_name test.himanshukukreja.in;
    root /var/www/test-app;
    index index.html;
    location / { try_files $uri $uri/ /index.html; }
}

sudo ln -s /etc/nginx/sites-available/test-app /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# HTTPS
sudo certbot --nginx -d test.himanshukukreja.in
```

### Option B — GitHub Pages (zero infra)

1. Push this folder to a GitHub repo
2. Go to **Settings → Pages → Source → Deploy from branch → `main` / `/ (root)` or `/demo-app`**
3. Site is live at `https://your-username.github.io/repo-name/`

### Option C — Serve locally for testing

```bash
cd demo-app
python -m http.server 3000
# open http://localhost:3000
```
