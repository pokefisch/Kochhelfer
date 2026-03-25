import scrapping
import communication

def main():
    url = input("Enter the recipe URL: ")
    scrapping.fetch(url)
if __name__ == "__main__":
    main()