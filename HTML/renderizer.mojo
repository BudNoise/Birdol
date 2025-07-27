from SDL2 import *
alias test = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Simple HTML Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 2rem;
            background-color: #f0f0f0;
            color: #333;
        }
        header {
            background-color: #0044cc;
            color: white;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 2rem;
        }
        main {
            background: white;
            padding: 1rem 2rem;
            border-radius: 0.5rem;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        footer {
            margin-top: 2rem;
            font-size: 0.9rem;
            color: #666;
        }
    </style>
</head>
<body>
    <header>
        <h1>Welcome to My Page</h1>
    </header>
    <main>
        <p>This is a basic HTML page structure. You can add your content here.</p>
    </main>
    <footer>
        <p>© 2025 Your Name</p>
    </footer>
</body>
</html>
"""
