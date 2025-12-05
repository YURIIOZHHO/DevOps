import os, yaml, logging
from datetime import datetime

os.makedirs("logs", exist_ok=True)
logging.basicConfig(filename="logs/app.log", level=logging.INFO)

with open("config.yaml") as f:
    config = yaml.safe_load(f)

logging.info(f"App started with config: {config}")

os.makedirs("data/uploads", exist_ok=True)
with open("data/uploads/sample.txt", "w") as f:
    f.write("Sample user data\n")
logging.info("User data saved")

os.makedirs("output", exist_ok=True)
with open("output/report.txt", "w") as f:
    f.write(f"Report generated at {datetime.now()}\n")
logging.info("Report generated")

print("App finished successfully")
