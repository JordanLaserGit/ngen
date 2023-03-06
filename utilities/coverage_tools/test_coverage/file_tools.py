""""
Tools for finding files within a repo


"""
import os


class Files():


    def __init__(self,top_folders,file_type):

        self.file_type       = file_type
        self.top_folder      = top_folders

        self.path_to_project = None
        self.files_path      = dict()        

        self.folders                       = dict()
        self.folders_ignore                = dict()
        self.folders_ignore_default        = dict()      
        self.folders_ignore_wo_file_type   = dict()
        self.folders_ignore_with_file_type = dict()

        self.files         = dict()
        self.files_ignore  = dict()
        self.files_ignored = dict()     

        for jtop in top_folders:    

            self.files_path[jtop] = None

            self.folders[jtop]                        = []    
            self.folders_ignore[jtop]                 = []                
            self.folders_ignore_default[jtop]         = []        
            self.folders_ignore_wo_file_type[jtop]    = []  
            self.folders_ignore_with_file_type[jtop]  = [] 

            self.files[jtop]          = []          
            self.files_ignore[jtop]   = []  
            self.files_ignored[jtop]  = [] 

        self.verbose       = True

    def default_folders_leave_out(self,top,libs):
        self.folders_ignore_default[top] = libs
        self.folders_leave_out(top,libs)
        return

    def folders_leave_out(self,top,libs):
        for jfile in libs:
            self.folders_ignore[top].append(jfile)
        return

    def files_leave_out(self,top,files):
        for jfile in files:
            self.files_ignore[top].append(jfile)
        return        

    def find_folders(self):

        for jtop in self.files_path:

            # Get all directories in test path
            dirs = [x[0] for x in os.walk(self.files_path[jtop])]

            # Remove directories that include folders we want to leave out
            dirs_keep          = []
            dirs_leave_with_file_type = []
            for jdir in dirs:
                dir_ok = True
                for j,dir_leave_out in enumerate(self.folders_ignore[jtop]):
                    if jdir.find(dir_leave_out) > 0:
                        dir_ok = False
                        dir_has_file_type = False
                        files = os.listdir(jdir)
                        for jfile in files:        
                            if jfile.split('.')[-1] in self.file_type:
                                dir_has_file_type = True
                                break
                        if dir_has_file_type:
                            dirs_leave_with_file_type.append(jdir)
                        break
                if dir_ok:
                    dirs_keep.append(jdir)        


            # Save folders that are found and ignored
            self.folders[jtop] = dirs_keep
            self.folders_ignore_with_file_type[jtop] = dirs_leave_with_file_type

            if len(dirs_leave_with_file_type) > 0:
                # Find all files of type that were ignored
                file_oftype_in_ignored_folder   = self.find_files(self.folders_ignore_with_file_type,{jtop:[]})
                for jfile in file_oftype_in_ignored_folder[jtop]:
                    self.files_ignored[jtop].append(jfile)


    def find_files(self,folders=None,files_ignore=None):
        if folders is None:
            folders = self.folders
        if files_ignore is None:
            files_ignore = self.files_ignore

        files_found     = dict()
        leave_out_files = dict()

        # Loop through remaining directories and find all file_type files
        for jtop in folders:
            folders_top = folders[jtop]
            files_found[jtop]     = []
            leave_out_files[jtop] =  []
            
            for jdir in folders_top:
                files = os.listdir(jdir)
                for jfile in files:        
                    if jfile.split('.')[-1] in self.file_type:            
                        full_path = os.path.join(jdir,jfile)
                        relative_path = os.path.relpath(full_path,self.files_path[jtop])
                        ii_keep = True
                        for kfile in files_ignore[jtop]:
                            if kfile.find(jfile) >= 0:
                                ii_keep = False
                                break
                        if not ii_keep:
                            leave_out_files[jtop].append(relative_path)
                        else:
                            files_found[jtop].append(relative_path)  

            if jtop in files_ignore.keys():
                if len(files_ignore[jtop]) > 0:
                    # Make sure all requested files were ignored
                    for jfile in self.files_ignore[jtop]:
                        ii_ignored = False
                        for kfile in leave_out_files[jtop]:
                            if kfile.find(jfile) >= 0:
                                ii_ignored = True
                                break
                        if not ii_ignored:
                            raise Exception(f'{jfile} not ignored!! Ignored:{leave_out_files[jtop]}')
                    for jfile in files_ignore[jtop]:
                        self.files_ignored[jtop].append(jfile)


                    if self.verbose:
                        print(f'\n------- {self.file_type} FILES INCLUDED -------')
                        self.print_files(self.files[jtop])
                        print(f'\n------- {self.file_type} FILES EXCLUDED -------')
                        self.print_files(self.files_ignored[jtop])  


        return files_found


    def print_files(self,files):
        for jfile in files:
            print(f'{jfile}')


    def set_project_path(self,project_path):
        self.path_to_project = project_path
        
        for jtop in self.top_folder:
            self.files_path[jtop] = os.path.join(self.path_to_project, jtop)
        print(f'Looking for {self.file_type} files in {self.files_path}')
