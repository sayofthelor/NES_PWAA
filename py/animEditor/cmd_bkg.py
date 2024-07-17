from tkinter import filedialog
from tkinter import messagebox
import os


def cmd_bkg(event=None):
    print("Command: BKG")
    # ask for file
    filetypes = (("PNG files", "*.png"), ("All files", "*.*"))
    fn = filedialog.askopenfilename(title="Choose Image Project File", initialdir="./", filetypes=filetypes)

    # if does not exist
    if not os.path.exists(fn):
        if fn == "":
            return "", False
        messagebox.showerror(title="Error Opening Background Image", message="Selected file does not exist")
        return "", False

    #
    return fn, True
