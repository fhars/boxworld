var   b2Vec2 = Box2D.Common.Math.b2Vec2
,   b2AABB = Box2D.Collision.b2AABB
,   b2BodyDef = Box2D.Dynamics.b2BodyDef
,   b2Body = Box2D.Dynamics.b2Body
,   b2FixtureDef = Box2D.Dynamics.b2FixtureDef
,   b2Fixture = Box2D.Dynamics.b2Fixture
,   b2World = Box2D.Dynamics.b2World
,   b2MassData = Box2D.Collision.Shapes.b2MassData
,   b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
,   b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
,   b2DebugDraw = Box2D.Dynamics.b2DebugDraw
,   b2MouseJointDef =  Box2D.Dynamics.Joints.b2MouseJointDef
,   b2PrismaticJointDef = Box2D.Dynamics.Joints.b2PrismaticJointDef
;

function get_console () {
  var c = this.console?this.console:{};
  var m = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
           "trace", "group", "groupCollapsed", "groupEnd", "time", "timeEnd"];
  function f () {}
  for (var i = 0; i < m.length; i++) if (!c[m[i]]) c[m[i]]=f;
  return c;
}

function instantiateBody(world, fixDef, bodyDef, x, y, ud) {
    bodyDef.position.x = x;
    bodyDef.position.y = y;
    var body =  world.CreateBody(bodyDef);
    body.SetUserData(ud);
    body.CreateFixture(fixDef);
    return body
}

function makebox(world, fixDef, w, h, x, y, ud) {
    var bodyDef = new b2BodyDef;
    bodyDef.type = b2Body.b2_dynamicBody;
    fixDef.shape = new b2PolygonShape;
    fixDef.shape.SetAsBox(w, h);
    return instantiateBody(world, fixDef, bodyDef, x, y, ud);
}
function makesquare(world, fixDef, w, x, y, ud) {
    return makebox(world, fixDef, w, w, x, y, ud);
}

function makecircle(world, fixDef, r, x, y, ud) {
    var bodyDef = new b2BodyDef;
    bodyDef.type = b2Body.b2_dynamicBody;
    fixDef.shape = new b2CircleShape(r);
    return instantiateBody(world, fixDef, bodyDef, x, y, ud);
}

function init() {
    var console = get_console();

    var world = new b2World(
        new b2Vec2(0, 10)    //gravity
        ,  true                 //allow sleep
    );

    var fixDef = new b2FixtureDef;
    fixDef.density = 2.0;
    fixDef.friction = 1.0;
    fixDef.restitution = 0.3;

    var bodyDef = new b2BodyDef;

    //create ground
    bodyDef.type = b2Body.b2_staticBody;
    fixDef.shape = new b2PolygonShape;
    fixDef.shape.SetAsBox(20, 2);
    bodyDef.position.Set(10, 400 / 30 + 1.8);
    var body = world.CreateBody(bodyDef);
    body.CreateFixture(fixDef);
    body.SetUserData("Ground")
    fixDef.friction = 0.0;
    bodyDef.position.Set(10, -1.8);
    body = world.CreateBody(bodyDef);
    body.CreateFixture(fixDef);
    body.SetUserData(0)
    fixDef.friction = 1.0;
    fixDef.shape.SetAsBox(2, 14);
    bodyDef.position.Set(-1.8, 13);
    var left_border = world.CreateBody(bodyDef);
    left_border.CreateFixture(fixDef);
    left_border.SetUserData(0)
    bodyDef.position.Set(21.8, 13);
    body = world.CreateBody(bodyDef);
    body.CreateFixture(fixDef);
    body.SetUserData(0)

    //create some objects
    bodyDef.type = b2Body.b2_dynamicBody;
    var objs = [
        makebox(world, fixDef, 1.8, 0.9,
                Math.random() * 10,
                Math.random() * 9 + 2,
                "Rect1"),
        makebox(world, fixDef, 1.5, 0.75,
                Math.random() * 10,
                Math.random() * 9 + 2,
                "Rect2"),
        makebox(world, fixDef, 1.2, 0.6,
                Math.random() * 10,
                Math.random() * 9 + 2,
                "Rect3"),
        makebox(world, fixDef, 0.9, 0.45,
                Math.random() * 10,
                Math.random() * 9 + 2,
                "Rect4"),
        makesquare(world, fixDef,
                   0.5 * Math.random() + 0.9,
                   Math.random() * 10,
                   Math.random() * 9 + 2,
                   "Square1"),
        makesquare(world, fixDef,
                   0.5 * Math.random() + 0.9,
                   Math.random() * 10,
                   Math.random() * 9 + 2,
                   "Square2")
/* this is too much to run in the update function
        makecircle(world, fixDef,
                   Math.random() + 0.4, //radius
                   Math.random() * 10,
                   Math.random() * 9 + 2,
                   "Circ1"),
        makecircle(world, fixDef,
                   Math.random() + 0.6, //radius
                   Math.random() * 10,
                   Math.random() * 9 + 2,
                   "Circ2")
*/
    ];
    var labels = [];
    for(var i = 0; i < objs.length; ++i) {
        labels[i] = objs[i].GetUserData();
    }
    initializePlanner(labels);

    fixDef.density = 500.0;
    fixDef.friction = 0.1;
    var crane = makebox(world, fixDef, 0.5, 0.1, 10, 0.5, "Pad");
    var worldAxis = new b2Vec2(1.0, 0.0);
    var jointDef = new b2PrismaticJointDef();
    jointDef.Initialize(left_border, crane, new b2Vec2(0.5, 0.5), worldAxis);
    jointDef.lowerTranslation= -9.0;
    jointDef.upperTranslation= 9.0;
    jointDef.enableLimit     = true;
    jointDef.maxMotorForce   = 1.0;
    jointDef.motorSpeed      = 0.0;
    jointDef.enableMotor     = true;
    world.CreateJoint(jointDef);

    var beam;

    //setup debug draw
    var debugDraw = new b2DebugDraw();
    debugDraw.SetSprite(document.getElementById("canvas").getContext("2d"));
    debugDraw.SetDrawScale(30.0);
    debugDraw.SetFillAlpha(0.5);
    debugDraw.SetLineThickness(1.0);
    debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
    world.SetDebugDraw(debugDraw);

    window.setInterval(update, 1000 / 60);

    //mouse

    var mouseX, mouseY, mousePVec, isMouseDown, selectedBody, mouseJoint;
    var canvasPosition = getElementPosition(document.getElementById("canvas"));

    document.addEventListener("mousedown", function(e) {
        isMouseDown = true;
        handleMouseMove(e);
        document.addEventListener("mousemove", handleMouseMove, true);
    }, true);

    document.addEventListener("mouseup", function() {
        document.removeEventListener("mousemove", handleMouseMove, true);
        isMouseDown = false;
        mouseX = undefined;
        mouseY = undefined;
    }, true);

    function handleMouseMove(e) {
        mouseX = (e.clientX - canvasPosition.x) / 30;
        mouseY = (e.clientY - canvasPosition.y) / 30;
    };

    function getBodyAtMouse() {
        mousePVec = new b2Vec2(mouseX, mouseY);
        var aabb = new b2AABB();
        aabb.lowerBound.Set(mouseX - 0.001, mouseY - 0.001);
        aabb.upperBound.Set(mouseX + 0.001, mouseY + 0.001);

        // Query the world for overlapping shapes.

        selectedBody = null;
        world.QueryAABB(getBodyCB, aabb);
        return selectedBody;
    }

    function getBodyCB(fixture) {
        if(fixture.GetBody().GetType() != b2Body.b2_staticBody) {
            if(fixture.GetShape().TestPoint(fixture.GetBody().GetTransform(), mousePVec)) {
                selectedBody = fixture.GetBody();
                return false;
            }
        }
        return true;
    }

    //update

    var simulating = 1;
    var planning = 2;
    var done = 3;
    var acting = 4;
    var state = simulating;
    var action = [];
    var was_running = true;

    var statenames = ["", "SIMULATING", "PLANNING", "DONE", "ACTING"];

    var null_v = new b2Vec2(0,0);


    function switch_state(st) {
        state = st;
        if (state == simulating) {
            was_running = true;
        }
        console.log("Switching to state " + statenames[state]);
    }

    var picked = undefined;
    var pick_y;

    function drop_object(targ) {
        if(beam) {
            world.DestroyJoint(beam);
            beam = undefined;
            picked = undefined;
        }
        switch_state(simulating);
    }

    function pick_object(targ) {
        console.log("Activating tractor beam on "+objs[targ].GetUserData());
        var jointDef = new b2PrismaticJointDef();
        var axis = crane.GetWorldCenter().Copy();
        var obj = objs[targ];
        picked = targ;
        pick_y = 14;
        axis.Subtract(obj.GetWorldCenter());
        axis.Normalize();
        jointDef.Initialize(crane, obj, crane.GetWorldCenter(), axis);
        jointDef.lowerTranslation= -1.0;
        jointDef.upperTranslation= obj.GetWorldCenter().y - 2.4;
        jointDef.enableLimit     = true;
        jointDef.maxMotorForce   = 200 * obj.GetMass();
        jointDef.motorSpeed      = 4.0;
        jointDef.enableMotor     = true;
        beam=world.CreateJoint(jointDef);
        switch_state(simulating);
    }

    var t_pos;
    function position(targ, operation) {
        var cp = crane.GetWorldCenter();
        var cv = crane.GetLinearVelocity().x
        if (targ == -1) {
            if (undefined == t_pos) {
                if (objs[0].GetWorldCenter().x < 10) {
                    t_pos = 10.5 + 7.5 * Math.random();
                } else {
                    t_pos = 9.5 - 7.5 * Math.random();
                }
            }
        } else {
            t_pos = objs[targ].GetWorldCenter().x;
        }
        var diff = t_pos - cp.x;
        var force = 0;
        var add_force = 0;
        if (undefined != picked) {
            add_force = 2 * objs[picked].GetMass();
        }
        if (Math.abs(diff) < 0.4) {
            if (Math.abs(cv) < 0.4) {
                force = 0;
                crane.SetLinearVelocity(null_v);
                t_pos = undefined;
                operation.apply(this,[targ]);
            } else {
                force = -(50 + add_force) * cv + 20 * diff;
            }
        }  else if (Math.abs(diff) < 1.8) {
            if (Math.abs(cv) < 2 * Math.abs(diff)) {
                force = -(40 + 2 * add_force) * cv + 20 * diff;
            } else {
                force = -(40 + 2 * add_force) * cv;
            }
        } else {
            if (Math.abs(cv) < 4) {
                force = 60 * diff;
            } else {
                force = -(20 + add_force) * cv;
            }
        }
        force = new b2Vec2(3 * force, 0);
        crane.ApplyForce(force, cp);
    }

    function perform(action) {
        var a = action;
        var act = a[0];
        var targ = a[1];
        if (act == 1) { // pick an object up
            if (beam) {
                drop_object()
            } else {
                position(targ, pick_object)
            }
        } else {
            position(targ, drop_object)
        }
    }


    function update() {
        var world_state = [];
        if (!isMouseDown) {
            if (state == simulating) {
                (function(){
                    var is_running = false;
                    var y;
                    var holding = false;
                    if (undefined != picked) {
                        y = objs[picked].GetWorldCenter().y;
                        var old_y = pick_y;
                        pick_y = 0.95 * pick_y + 0.05 * y;
                        if (Math.abs(old_y - pick_y) < 0.001 &&
                            Math.abs(objs[picked].GetWorldCenter().y < 3)) {
                            holding = true;
                            world_state.push(["holding", objs[picked].GetUserData()]);
                        }
                    }
                    for(var i = 0; i < objs.length; i = i + 1) {
                        var asleep = !objs[i].IsAwake() || (i==picked && holding);
                        is_running = is_running || !asleep;
                    }
                    if(was_running && !is_running) {
                        console.log("Stopped simulating");
                        for(var i = 0; i < objs.length; i = i + 1) {
                            var test_body = objs[i];
                            var center = test_body.GetWorldCenter();
                            var obj_ud = test_body.GetUserData();
                            var cont = test_body.GetContactList();
                            while (cont) {
                                var ud = cont.other.GetUserData();
                                if (ud != 0 && cont.contact.IsTouching()) {
                                    var rel = cont.other.GetWorldCenter().Copy();
                                    rel.Subtract(center);
                                    rel.Normalize();
                                    if (rel.y < -0.5) {
                                        world_state.push(["on", obj_ud, ud]);
                                    }
                                }
                                cont = cont.next;
                            }
                        }
                        switch_state(planning);
                        console.log("State: "+world_state);
                    }
                    if(!was_running && is_running) {
                        console.log("Started simulating");
                    }

                    was_running = is_running;
                })();
            }
        }

        if (state == planning) {
            var a = runPlanner(world_state).slice(1);
            var act = a[0];
            var res = a[1];
            action = act.slice(1);
            switch_state(res);
        }
        if (state == acting) {
            perform(action);
        }
        if(isMouseDown && (!mouseJoint)) {
            var body = getBodyAtMouse();
            if(body) {
                var md = new b2MouseJointDef();
                md.bodyA = world.GetGroundBody();
                md.bodyB = body;
                md.target.Set(mouseX, mouseY);
                md.collideConnected = true;
                md.maxForce = 300.0 * body.GetMass();
                mouseJoint = world.CreateJoint(md);
                body.SetAwake(true);
                switch_state(simulating);
            }
        }

        if(mouseJoint) {
            if(isMouseDown) {
                mouseJoint.SetTarget(new b2Vec2(mouseX, mouseY));
            } else {
                world.DestroyJoint(mouseJoint);
                mouseJoint = null;
            }
        }

        world.Step(1 / 60, 10, 10);
        world.DrawDebugData();
        world.ClearForces();
    };

    //helpers

    //http://js-tut.aardon.de/js-tut/tutorial/position.html
    function getElementPosition(element) {
        var elem=element, tagname="", x=0, y=0;

        while((typeof(elem) == "object") && (typeof(elem.tagName) != "undefined")) {
            y += elem.offsetTop;
            x += elem.offsetLeft;
            tagname = elem.tagName.toUpperCase();

            if(tagname == "BODY")
                elem=0;

            if(typeof(elem) == "object") {
                if(typeof(elem.offsetParent) == "object")
                    elem = elem.offsetParent;
            }
        }

        return {x: x, y: y};
    }
};
