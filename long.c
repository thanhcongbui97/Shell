#include <stdio.h>
#include <time.h>
#include <X11/Xutil.h>
#include <assert.h>
#include "lib_mouse.h"

void test_mouse(void *_self,int x_des, int y_des, int speed)
{
	mouse *self = _self;
	self->move(self,x_des,y_des,1,speed);	
}

int main(int argc, char *argv[])
{
	int i = 0;
	Display *dpy;
	Window root_window;

    	dpy = XOpenDisplay(0);
    	root_window = XRootWindow(dpy, 0);
    	XSelectInput(dpy, root_window, KeyReleaseMask);
	mouse *x = New(0, 0, dpy, root_window, constructor, destructor,
		mouse_click, mouse_double_click, mouse_release, move_xy
		, get_attribute, mouse_press);

	assert(x);
	show_attribute(x);

	test_mouse(x, 50, 20, 4);
	x->click(x,1);
	sleep(1);
	x->dclick(x);
	 for ( i = 0; i< 2; i++) 
	 {
		test_mouse(x,800, 6000, 4);
		usleep(100000);
	 	test_mouse(x,100, 20, 4);
		sleep(1);
	 }
	 x->click(x,1);
	x->dstor(x);
	
    return 0;
}
