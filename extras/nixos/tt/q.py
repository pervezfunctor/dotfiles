# type: ignore

import questionary
import yaml

answers = {
    "project-description": questionary.text("Project description?").ask(),
    "author": questionary.text("Author?").ask(),
}

with open("data.yaml", "w") as f:
    yaml.dump(answers, f)
