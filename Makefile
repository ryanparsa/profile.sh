.PHONY: install clean

SRC_FILE = profile.sh
DEST_FILE = ~/.profile.sh


# Install target to copy profile.sh to ~/.profile.sh
install: $(SRC_FILE)
	cp $(SRC_FILE) $(DEST_FILE)
	chmod +x $(DEST_FILE)

# Clean target to remove ~/.profile.sh
clean:
	rm -f $(DEST_FILE)

