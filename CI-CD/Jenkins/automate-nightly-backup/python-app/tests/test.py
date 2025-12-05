import os

def test_data_folder_exists():
    assert os.path.isdir("data/uploads")

def test_output_folder_exists():
    assert os.path.isdir("output")
