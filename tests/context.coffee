require('mocha')
expect = require('chai').expect
ctx = require(__dirname + '/../lib/context.coffee')

describe('Context', ->
  
  it('Should build flat object', (done) ->
    to = 
      foo: true
      str: 1
      some: 'stuff'
  
    to = ctx.build(to)

    expect(to.$this).to.exist
    expect(to.$root).to.exist
    expect(to.$parent).to.exist
    expect(to.foo).to.equal(true)
    expect(to.str).to.equal(1)
    expect(to.some).to.equal('stuff')
    
    done()
  )
  
  it('Should build one object deep', (done) ->
    to = 
      foo: true
      some:
        foo: 'bar'
  
    oSome = to.some
  
    to = ctx.build(to)

    expect(to.foo).to.equal(true)
    expect(to.some.$this).to.exist
    expect(to.some.$root).to.exist
    expect(to.some.$parent).to.exist
    expect(to.some).to.equal(oSome)
    expect(to.some.$parent).to.equal(to)
    expect(to.some.foo).to.equal('bar')
    expect(to.some.$this.foo).to.equal('bar')
    
    done()
  )
  
  it('Should build multi object deep', (done) ->
    to = 
      foo: true
      some:
        foo: 'bar'
        bar:
          mystuff: true
  
    someParent = to
    someRoot = to
    toParent = to
    toRoot = to
    barParent = to.some
    barRoot = to
    
    to = ctx.build(to)

    expect(to.some.bar.mystuff).to.equal(true)
    expect(to.some.$parent).to.equal(someParent)
    expect(to.some.$root).to.equal(someRoot)
    expect(to.$parent).to.equal(toParent)
    expect(to.$root).to.equal(toRoot)
    expect(to.some.bar.$parent).to.equal(barParent)
    expect(to.some.bar.$root).to.equal(barRoot)
    
    done()
  )
  
  it('Should one array deep', (done) ->
    to = 
      foo: true
      users: [1,2,3]
  
    parent = to.users
    root = to
  
    to = ctx.build(to)

    expect(to.users[0].$this).to.equal(1)
    expect(to.users[1].$this).to.equal(2)
    expect(to.users[2].$this).to.equal(3)
    expect(to.users[0].$parent).to.equal(parent)
    expect(to.users[0].$root).to.equal(root)
    
    done()
  )
  
  it('Should multi array deep', (done) ->
    to = 
      foo: true
      users: [{
        name: 'Bob'
        roles: ['admin', 'worker']
      }]
  
    parent = to.users
    rolesParent = to.users[0].roles
    root = to
  
    to = ctx.build(to)

    expect(to.users[0].$root).to.equal(root)
    expect(to.users[0].$this.roles).to.exist
    expect(to.users[0].roles[0].$this).to.equal('admin')
    expect(to.users[0].roles[0].$parent).to.equal(rolesParent)
    expect(to.users[0].roles[0].$root).to.equal(root)
    
    done()
  )
  
)