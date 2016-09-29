#!/usr/bin/python
#!/usr/local/bin/python

from Tkinter import *

class RegFile:
    count = 0    # Registers
    value = []   # Current values (store as string)
    idlabel = []  # Tkinter label for ID
    vallabel = []   # Tkinter label for register
    lastWrite = -1  # Index of last register updated

    def __init__(self, master, idstring):
        idlist = idstring.split()
        self.count = len(idlist)
        self.value = ['' for i in range(0, self.count)]
        self.idlabel = [[] for i in range(0, self.count)]
        self.vallabel = [[] for i in range(0, self.count)]
        self.lastWrite = -1
        frame = Frame(master)
        frame.pack()
        for i in range(0, self.count):
            rframe = Frame(frame)
            rframe.pack(side=LEFT)
            self.idlabel[i] = Label(rframe, width = 8,
                                    text = idlist[i])
            self.idlabel[i].pack(side=TOP)
            self.vallabel[i] = Label(rframe, width = 8,
                                  font=("Courier", 12),
                                  bg = 'white',
                                  relief=SUNKEN, anchor=E)
            self.vallabel[i].pack(side=BOTTOM)

    def refresh(self):
        for i in range(0, self.count):
            self.vallabel[i].config(text=self.value[i])
            if i == self.lastWrite:
                self.vallabel[i].config(bg='lightblue')
            else:
                self.vallabel[i].config(bg='white')
            

    def set(self, index, val):
        if index >= 0 and index < self.count:
            self.value[index] = val
            if len(val) > 0:
                self.lastWrite = index
            else:
                self.lastWrite = -1
        self.refresh()

    def clear(self):
        for i in range(0,self.count):
            self.value[i] = ''
        self.lastWrite = -1
        self.refresh()

x86ids = '%eax %ecx %edx %ebx %esp %ebp %esi %edi'

class Display:
    master = []
    regfile = []

    def __init__(self, master):
        self.master = master
        self.regfile = RegFile(master, x86ids)
        
root = Tk()
d = Display(root)
