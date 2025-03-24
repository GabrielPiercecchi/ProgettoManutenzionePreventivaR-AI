import os

def count_txt_files(directory):
    txt_count = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.txt'):
                txt_count += 1
    return txt_count

# Specifica il percorso della cartella
directory = r"B - PHM America 2023 - Dataset\Data_Challenge_PHM2023_test_data"

# Conta i file .txt
txt_file_count = count_txt_files(directory)

print(f"Numero di file .txt nella cartella '{directory}': {txt_file_count}")